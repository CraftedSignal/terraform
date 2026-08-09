# Releases

The package should be consumed through provider-scoped Git tags.

## Versioning

Use semantic versioning within the provider prefix:

- `gcp/vMAJOR.MINOR.PATCH`
- Major: breaking input or output behavior, or replacement-heavy architecture changes.
- Minor: backwards-compatible resources, inputs, or outputs.
- Patch: fixes and documentation updates.

## Automated Releases

The `Release` GitHub Actions workflow runs on pushes to `main`.
It discovers changed top-level provider packages, runs the release gates, computes the next provider-scoped SemVer tag from Conventional Commits, and creates the GitHub Release directly.

The first release for a provider starts at `v0.1.0`.
After that:

- `feat:` commits create a minor release.
- `!` or `BREAKING CHANGE:` commits create a major release.
- Other commits that touch the provider package create a patch release.

## Manual Checklist

1. Run `terraform fmt -recursive`.
2. Run `terraform init -backend=false`, `terraform validate`, and `terraform test` in `gcp/modules/platform`.
3. Run `terraform init -backend=false` and `terraform validate` in each example.
4. Run TFLint, Checkov, and Trivy.
5. Push to `main` and let CI/CD create the provider tag and GitHub Release.

## Consumer Pinning

Consumers should pin a version:

```hcl
module "craftedsignal" {
  source = "git::https://github.com/CraftedSignal/terraform.git//gcp/modules/platform?ref=gcp/v0.1.0"
}
```

Do not consume `main` from production environments.
