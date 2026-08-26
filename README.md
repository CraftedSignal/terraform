# CraftedSignal Terraform

Customer-facing Terraform packages for CraftedSignal infrastructure.

This repository is organized as a provider-aware Terraform monorepo so new clouds can be added without changing the public repository shape.

```text
terraform/
  gcp/
    modules/
      platform/
    examples/
      production/
    docs/
  aws/
    # reserved for a future package
```

## Packages

| Package | Status | Module source |
| --- | --- | --- |
| `gcp` | Production-ready package | `git::https://github.com/CraftedSignal/terraform.git//gcp/modules/platform?ref=gcp/v0.2.0` |

## Release Model

Use provider-scoped Git tags:

- `gcp/vMAJOR.MINOR.PATCH`
- `azure/vMAJOR.MINOR.PATCH` when Azure exists
- `aws/vMAJOR.MINOR.PATCH` when AWS exists

The release workflow creates these tags and GitHub Releases automatically from `main`.
Each top-level provider package releases independently when files under that provider directory change.

## Repository Rules

- Do not commit live Terraform state.
- Do not commit `*.tfvars` files with customer values.
- Do not commit internal CraftedSignal project IDs, account IDs, domains, tokens, or secrets.
- Do not package demo infrastructure.
- Provider packages must include production examples, security notes, upgrade notes, and generated module docs.

See `docs/repository-settings.md` for the required GitHub repository settings.
