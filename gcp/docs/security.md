# Security Notes

The module defaults are production-oriented:

- GKE nodes are private.
- Confidential GKE Nodes can be enabled for new clusters or planned cluster cutovers.
- Cloud SQL has no public IPv4 address.
- Cloud SQL runs PostgreSQL 18, requires trusted-client-certificate SSL mode, and is encrypted with CMEK.
- Secret Manager secrets are encrypted with CMEK.
- Artifact Registry is encrypted with CMEK.
- Application-level tenant DEKs are wrapped by a dedicated HSM-backed `platform-kek` key.
- Binary Authorization is enforced with a KMS-backed attestor.
- GKE Workload Identity is enabled.
- Runtime workloads use narrowly scoped service accounts.
- A key-broker service account is created and receives platform KEK access by default; direct runtime service-account KEK access is opt-in.
- Confidential Space attestation can restrict KMS access to stable attested workloads matching approved image digests, image-signing keys, or key-broker service accounts.
- Artifact Registry writes are granted only to explicit IAM members.
- Cloud Armor starts OWASP rules in preview mode to avoid blocking valid detection content.

## Independent Security Testing

Independent penetration testing and major-change security reviews are part of the security assurance process for the platform and managed infrastructure. Findings should be triaged, assigned, remediated, and tracked through closure alongside deployment evidence.

For customer-operated deployments, keep any customer-run penetration test reports, remediation tickets, Terraform plans, Binary Authorization attestations, and KMS audit logs in the customer's evidence archive. Those records are often the clearest way to show that the operating model, not only the codebase, has been reviewed.

## Secrets

The module creates Secret Manager secret containers, not secret versions, for required runtime configuration. Write secret values out of band unless the customer deliberately chooses to manage those values in Terraform state.

If `cloudsql.create_password_users = true`, Terraform generates database passwords and stores them in Secret Manager. Those generated values still live in Terraform state. Prefer Cloud SQL IAM database authentication where possible.

## Cloud Armor

Detection engineering content can legitimately contain SQL, script-like strings, path traversal examples, and raw protocol payloads. For that reason, OWASP WAF rules default to `preview = true`. Review Cloud Armor logs before enforcing them.

## IAM Database Authentication

Terraform can create Cloud SQL IAM database users. PostgreSQL schema privileges still need to be granted inside the database after the first apply. Use `gcp/docs/database-grants.sql.tpl` as the starting point.

Because Cloud SQL uses `TRUSTED_CLIENT_CERTIFICATE_REQUIRED`, application and Temporal database clients should use the Cloud SQL Auth Proxy or Cloud SQL connectors. Direct private-IP clients must present trusted client certificates.

## Application Encryption KMS

The module creates a dedicated `platform-kek` Cloud KMS key for envelope encryption. Application code should use this key only to wrap and unwrap per-tenant data-encryption keys; content encryption stays in the application layer. This separates the data-encryption key that protects tenant content from the key-encryption key that governs whether a workload is allowed to unwrap it.

By default, the key-broker service account receives `roles/cloudkms.cryptoKeyEncrypterDecrypter` on the platform KEK. The app and worker service accounts do not receive direct KEK access unless `application_encryption.grant_runtime_service_accounts` is explicitly enabled. That keeps the default path aligned with a brokered key-access model instead of spreading decrypt permission across every runtime workload.

For sovereign deployments where the customer owns the KEK, enable `application_encryption.confidential_space_attestation` and use the exposed Workload Identity Pool/Provider outputs in the customer's KMS IAM policy. The customer-side IAM grant should target the attested identity, not a broad CraftedSignal service account.

```hcl
resource "google_kms_crypto_key_iam_member" "craftedsignal_attested_decrypt" {
  crypto_key_id = google_kms_crypto_key.customer_platform_kek.id
  role          = "roles/cloudkms.cryptoKeyDecrypter"
  member        = "principalSet://iam.googleapis.com/${module.craftedsignal.confidential_space_workload_identity_pool_name}/*"
}
```

The provider-side attestation condition always requires `CONFIDENTIAL_SPACE`, the `STABLE` support attribute, the expected GCP project number, and the configured key-broker service account. Add `allowed_image_digests`, `signing_key_fingerprints`, or explicit service accounts before granting customer-key access when the customer needs a narrower policy.

## Confidential Computing Boundaries

The module exposes two separate confidential-computing controls:

- `gke.confidential_nodes` enables Confidential GKE Nodes for supported GKE Autopilot clusters. This is an encrypted-memory/data-in-use control for Kubernetes nodes and workloads. Treat it as a cluster creation-time decision and use it for new clusters or planned cutovers.
- `application_encryption.confidential_space_attestation` creates a Confidential Space Workload Identity provider. This is an attested-identity control for key access. It lets a customer-owned KMS key trust only stable Confidential Space workloads that match the configured project, service account, image digest, or image-signing evidence.

Do not treat those controls as interchangeable. Confidential GKE Nodes protect memory for the GKE runtime; Confidential Space attestation gates access to keys or other confidential resources based on workload evidence. A sovereign deployment can use either one independently, or combine both when policy requires encrypted memory and attested key release.
