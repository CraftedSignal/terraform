# Upgrades

## Version Pins

Consumers must pin provider-scoped tags:

```hcl
module "craftedsignal" {
  source = "git::https://github.com/CraftedSignal/terraform.git//gcp/modules/platform?ref=gcp/v0.1.0"
}
```

Do not consume `main` from production.

## Upgrade Process

1. Read the release notes for every version between the current and target tag.
2. Run `terraform init -upgrade`.
3. Run `terraform plan` and review all replacements.
4. Confirm Cloud SQL, GKE, and KMS changes with the customer before apply.
5. Apply during a maintenance window when replacement or restart risk exists.

## Breaking Changes

Breaking changes require a new major version tag, for example `gcp/v2.0.0`.

