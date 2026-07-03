# Releases

The package should be consumed through provider-scoped Git tags.

## Versioning

Use semantic versioning within the provider prefix:

- `gcp/vMAJOR.MINOR.PATCH`
- Major: breaking input or output behavior, or replacement-heavy architecture changes.
- Minor: backwards-compatible resources, inputs, or outputs.
- Patch: fixes and documentation updates.

## Release Checklist

1. Run `terraform fmt -recursive`.
2. Run `terraform init -backend=false` and `terraform validate` in `gcp/modules/platform`.
3. Run `terraform init -backend=false` and `terraform validate` in each example.
4. Update `CHANGELOG.md`.
5. Tag the release, for example `git tag gcp/v0.1.0`.
6. Publish a GitHub Release with upgrade notes.

## Consumer Pinning

Consumers should pin a version:

```hcl
module "craftedsignal" {
  source = "git::https://github.com/CraftedSignal/terraform.git//gcp/modules/platform?ref=gcp/v0.1.0"
}
```

Do not consume `main` from production environments.

