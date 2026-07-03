# Security Notes

The module defaults are production-oriented:

- GKE nodes are private.
- Cloud SQL has no public IPv4 address.
- Cloud SQL requires encrypted client connections and is encrypted with CMEK.
- Secret Manager secrets are encrypted with CMEK.
- GKE Workload Identity is enabled.
- Runtime workloads use narrowly scoped service accounts.
- Artifact Registry writes are granted only to explicit IAM members.
- Cloud Armor starts OWASP rules in preview mode to avoid blocking valid detection content.

## Secrets

The module creates Secret Manager secret containers, not secret versions, for required runtime configuration. Write secret values out of band unless the customer deliberately chooses to manage those values in Terraform state.

If `cloudsql.create_password_users = true`, Terraform generates database passwords and stores them in Secret Manager. Those generated values still live in Terraform state. Prefer Cloud SQL IAM database authentication where possible.

## Cloud Armor

Detection engineering content can legitimately contain SQL, script-like strings, path traversal examples, and raw protocol payloads. For that reason, OWASP WAF rules default to `preview = true`. Review Cloud Armor logs before enforcing them.

## IAM Database Authentication

Terraform can create Cloud SQL IAM database users. PostgreSQL schema privileges still need to be granted inside the database after the first apply. Use `gcp/docs/database-grants.sql.tpl` as the starting point.

