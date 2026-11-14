# Upgrades

## Version Pins

Consumers must pin provider-scoped tags:

```hcl
module "craftedsignal" {
  source = "git::https://github.com/CraftedSignal/terraform.git//gcp/modules/platform?ref=gcp/v0.2.0"
}
```

Do not consume `main` from production.

## Google Provider v8

The platform module supports Google provider versions `>= 7.31, < 9.0`. Keep a provider version constraint in the consuming root module; the production example retains its v7 constraint so upgrading this module alone does not select a new provider major version.

Before selecting v8, review the [Google provider v8 upgrade guide](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/version_8_upgrade) for all resources in the root configuration. In particular, existing classic load balancers must explicitly set `load_balancing_scheme = "EXTERNAL"` on backend services and global forwarding rules to preserve their behavior. The platform module does not create those resources.

## Upgrade Process

1. Read the release notes for every version between the current and target tag.
2. Run `terraform init -upgrade`.
3. Run `terraform plan` and review all replacements.
4. Confirm Cloud SQL, GKE, and KMS changes with the customer before apply.
5. Apply during a maintenance window when replacement or restart risk exists.

## Breaking Changes

Breaking changes require a new major version tag, for example `gcp/v2.0.0`.
