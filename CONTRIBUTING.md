# Contributing

Keep this repo customer-facing:

- Do not commit state files, `.tfvars`, internal account IDs, or secret values.
- Keep examples production-shaped.
- Treat variables and outputs as public API.
- Add upgrade notes for breaking changes.
- Run `terraform fmt -recursive` and `terraform validate` before opening a PR.
- Keep provider packages independently releasable with provider-scoped tags such as `gcp/v0.1.0`.

