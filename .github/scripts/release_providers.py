#!/usr/bin/env python3
"""Plan and publish provider-scoped Terraform releases.

Provider packages are top-level directories that contain a modules/ or examples/
directory. Tags use the documented provider-scoped SemVer format:
<provider>/vMAJOR.MINOR.PATCH.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TAG_RE = re.compile(r"^(?P<provider>[A-Za-z0-9_-]+)/v(?P<major>0|[1-9]\d*)\.(?P<minor>0|[1-9]\d*)\.(?P<patch>0|[1-9]\d*)$")
COMMIT_RE = re.compile(r"^(?P<type>[A-Za-z]+)(?:\((?P<scope>[^)]+)\))?(?P<breaking>!)?:")
INITIAL_VERSION = (0, 1, 0)


def run(args: list[str], *, cwd: Path = ROOT, capture: bool = True) -> str:
    result = subprocess.run(
        args,
        cwd=cwd,
        check=True,
        text=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=None,
    )
    return result.stdout.strip() if capture else ""


def discover_packages() -> list[dict[str, str]]:
    packages = []
    for path in sorted(ROOT.iterdir()):
        if not path.is_dir() or path.name.startswith("."):
            continue
        if (path / "modules").is_dir() or (path / "examples").is_dir():
            packages.append({"provider": path.name, "directory": path.name})
    return packages


def parse_tag(tag: str, provider: str) -> tuple[int, int, int] | None:
    match = TAG_RE.match(tag)
    if not match or match.group("provider") != provider:
        return None
    return (
        int(match.group("major")),
        int(match.group("minor")),
        int(match.group("patch")),
    )


def latest_provider_tag(provider: str) -> tuple[str, tuple[int, int, int]] | None:
    tags = run(["git", "tag", "--list", f"{provider}/v*"]).splitlines()
    parsed = [(tag, parse_tag(tag, provider)) for tag in tags]
    versions = [(tag, version) for tag, version in parsed if version is not None]
    if not versions:
        return None
    return max(versions, key=lambda item: item[1])


def changed_files(directory: str, latest_tag: str | None) -> list[str]:
    if latest_tag:
        output = run(["git", "diff", "--name-only", f"{latest_tag}..HEAD", "--", directory])
    else:
        output = run(["git", "ls-tree", "-r", "--name-only", "HEAD", directory])
    return [line for line in output.splitlines() if line]


def commits_for(directory: str, latest_tag: str | None) -> list[dict[str, str]]:
    revision = f"{latest_tag}..HEAD" if latest_tag else "HEAD"
    output = run([
        "git",
        "log",
        "--reverse",
        "--format=%H%x00%s%x00%b%x1e",
        revision,
        "--",
        directory,
    ])
    commits = []
    for record in output.split("\x1e"):
        record = record.strip()
        if not record:
            continue
        parts = record.split("\x00", 2)
        if len(parts) != 3:
            continue
        sha, subject, body = parts
        commits.append({
            "sha": sha,
            "short_sha": sha[:7],
            "subject": subject.strip(),
            "body": body.strip(),
        })
    return commits


def commit_bump(commit: dict[str, str]) -> str:
    subject = commit["subject"]
    body = commit["body"]
    match = COMMIT_RE.match(subject)
    if "BREAKING CHANGE:" in body or "BREAKING-CHANGE:" in body:
        return "major"
    if match and match.group("breaking"):
        return "major"
    if match and match.group("type").lower() == "feat":
        return "minor"
    return "patch"


def highest_bump(commits: list[dict[str, str]], latest_tag: str | None) -> str:
    if not latest_tag:
        return "initial"
    priority = {"patch": 0, "minor": 1, "major": 2}
    bump = "patch"
    for commit in commits:
        candidate = commit_bump(commit)
        if priority[candidate] > priority[bump]:
            bump = candidate
    return bump


def bump_version(current: tuple[int, int, int] | None, bump: str) -> tuple[int, int, int]:
    if current is None:
        return INITIAL_VERSION
    major, minor, patch = current
    if bump == "major":
        return (major + 1, 0, 0)
    if bump == "minor":
        return (major, minor + 1, 0)
    return (major, minor, patch + 1)


def plan_releases() -> list[dict[str, object]]:
    releases = []
    for package in discover_packages():
        provider = package["provider"]
        directory = package["directory"]
        latest = latest_provider_tag(provider)
        latest_tag = latest[0] if latest else None
        latest_version = latest[1] if latest else None
        files = changed_files(directory, latest_tag)
        if not files:
            continue
        commits = commits_for(directory, latest_tag)
        bump = highest_bump(commits, latest_tag)
        next_version = bump_version(latest_version, bump)
        version = ".".join(str(part) for part in next_version)
        releases.append({
            "provider": provider,
            "directory": directory,
            "latest_tag": latest_tag,
            "latest_version": ".".join(str(part) for part in latest_version) if latest_version else None,
            "bump": bump,
            "version": version,
            "tag": f"{provider}/v{version}",
            "commits": commits,
            "changed_files": files,
        })
    return releases


def write_github_outputs(releases: list[dict[str, object]]) -> None:
    output_path = os.environ.get("GITHUB_OUTPUT")
    if not output_path:
        return
    with open(output_path, "a", encoding="utf-8") as output:
        output.write(f"has_releases={'true' if releases else 'false'}\n")
        output.write("releases<<JSON\n")
        output.write(json.dumps(releases, separators=(",", ":")))
        output.write("\nJSON\n")


def terraform_roots(directory: str) -> list[Path]:
    package_dir = ROOT / directory
    roots: list[Path] = []
    if any(package_dir.glob("*.tf")):
        roots.append(package_dir)
    for section in ("modules", "examples"):
        section_dir = package_dir / section
        if not section_dir.is_dir():
            continue
        for child in sorted(section_dir.iterdir()):
            if child.is_dir() and any(child.glob("*.tf")):
                roots.append(child)
    return roots


def check_releases(releases: list[dict[str, object]]) -> None:
    seen: set[Path] = set()
    for release in releases:
        directory = str(release["directory"])
        run(["terraform", "fmt", "-check", "-recursive", directory], capture=False)
        for root in terraform_roots(directory):
            if root in seen:
                continue
            seen.add(root)
            run(["terraform", "init", "-backend=false"], cwd=root, capture=False)
            run(["terraform", "validate"], cwd=root, capture=False)
            has_tests = any(root.glob("*.tftest.hcl")) or any((root / "tests").glob("*.tftest.hcl"))
            if has_tests:
                run(["terraform", "test"], cwd=root, capture=False)


def release_notes(release: dict[str, object]) -> str:
    provider = str(release["provider"])
    version = str(release["version"])
    latest_tag = release["latest_tag"]
    commits = release["commits"]
    changed_files = release["changed_files"]
    lines = [
        f"# {provider} v{version}",
        "",
        f"Provider package: `{provider}`",
        "",
    ]
    if latest_tag:
        lines.extend([f"Changes since `{latest_tag}`.", ""])
    else:
        lines.extend(["Initial provider-scoped release.", ""])
    if commits:
        lines.append("## Commits")
        for commit in commits:
            lines.append(f"- {commit['subject']} ({commit['short_sha']})")
        lines.append("")
    lines.append("## Changed Files")
    for path in changed_files:
        lines.append(f"- `{path}`")
    lines.append("")
    return "\n".join(lines)


def apply_releases(releases: list[dict[str, object]], repo: str, target: str) -> None:
    for release in releases:
        tag = str(release["tag"])
        title = f"{release['provider']} v{release['version']}"
        with tempfile.NamedTemporaryFile("w", encoding="utf-8", delete=False) as notes:
            notes.write(release_notes(release))
            notes_path = notes.name
        try:
            run([
                "gh",
                "release",
                "create",
                tag,
                "--repo",
                repo,
                "--target",
                target,
                "--title",
                title,
                "--notes-file",
                notes_path,
            ], capture=False)
        finally:
            Path(notes_path).unlink(missing_ok=True)


def load_plan(path: str) -> list[dict[str, object]]:
    with open(path, encoding="utf-8") as plan_file:
        return json.load(plan_file)


def main() -> int:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)

    plan_parser = subparsers.add_parser("plan")
    plan_parser.add_argument("--output", help="Write planned releases to this JSON file.")

    check_parser = subparsers.add_parser("check")
    check_parser.add_argument("--plan", required=True)

    apply_parser = subparsers.add_parser("apply")
    apply_parser.add_argument("--plan", required=True)
    apply_parser.add_argument("--repo", default=os.environ.get("GITHUB_REPOSITORY", ""))
    apply_parser.add_argument("--target", default=os.environ.get("GITHUB_SHA", "HEAD"))

    args = parser.parse_args()

    if args.command == "plan":
        releases = plan_releases()
        if args.output:
            with open(args.output, "w", encoding="utf-8") as output:
                json.dump(releases, output, indent=2)
                output.write("\n")
        write_github_outputs(releases)
        print(json.dumps(releases, indent=2))
        return 0

    if args.command == "check":
        check_releases(load_plan(args.plan))
        return 0

    if args.command == "apply":
        if not args.repo:
            print("GITHUB_REPOSITORY is required when --repo is not set.", file=sys.stderr)
            return 1
        apply_releases(load_plan(args.plan), args.repo, args.target)
        return 0

    return 1


if __name__ == "__main__":
    raise SystemExit(main())
