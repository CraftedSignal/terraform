# Repository Settings

Use these settings for the GitHub repository that hosts this Terraform monorepo.

## Branch Protection

Protect `main` and require:

- Pull request before merge.
- Linear history or squash merge.
- Conversation resolution before merge.
- Required status checks:
  - `CI / Terraform`
  - `CI / TFLint`
  - `Docs / terraform-docs`
  - `Security / TruffleHog`
  - `Security / Checkov`
- Signed commits if the organization standard requires it.

## Security Features

Enable:

- Dependabot alerts.
- Dependabot security updates.
- Secret scanning.
- Push protection.
- Code scanning alerts.

## Releases

Use provider-scoped tags:

- `gcp/v0.1.0`
- `aws/v0.1.0` when AWS exists

The release workflow publishes GitHub Releases for these tags.

