# Customer KMS Integration

Sovereign deployments can keep the key-encryption key in the customer's GCP project while CraftedSignal runs the workload. The customer grants key access to the attested Confidential Space identity, not to a broad human, CI, or runtime service account.

## Sovereignty Model

Customers can choose the boundary that fits their policy:

- Use the secured SaaS deployment with private GCP infrastructure, KMS/CMEK, signed releases, and Binary Authorization attestations.
- Use customer-controlled key material by granting a customer KMS key only to an attested Confidential Space identity.
- Run CraftedSignal on-premises or in a private cloud when the infrastructure itself must remain customer-operated.

Application-level encryption remains the same model across those options:

1. Tenant content is encrypted with tenant data-encryption keys.
2. Tenant data-encryption keys are wrapped by a KEK.
3. The KEK is held by CraftedSignal SaaS infrastructure or by the customer, depending on the sovereignty model.
4. The runtime unwraps a tenant DEK only through the configured key-access path.

Confidential Space provides attested key access. Confidential GKE Nodes or Confidential VMs provide encrypted-memory options for supported GCP runtimes. Use both when policy requires key release only to attested workloads and encrypted memory while those workloads process data.

## CraftedSignal Module Inputs

Enable the attestation provider and restrict it to approved workload evidence:

```hcl
module "craftedsignal" {
  source = "git::https://github.com/CraftedSignal/terraform.git//gcp/modules/platform?ref=gcp/v0.2.0"

  project_id              = var.project_id
  app_domain              = var.app_domain
  gke_rbac_security_group = var.gke_rbac_security_group

  application_encryption = {
    confidential_space_attestation = {
      enabled                  = true
      signing_key_fingerprints = var.confidential_space_signing_key_fingerprints
    }
  }
}
```

Confidential Space attestation is separate from Confidential GKE Nodes. Enable `gke.confidential_nodes` for a new GKE cluster or a planned cluster cutover when you want confidential node hardware for the Kubernetes runtime; use `application_encryption.confidential_space_attestation` when a customer-owned KMS key should trust only an attested key-broker workload.

For imported KMS deployments, provide every KMS key used by the module. That keeps CMEK explicit instead of silently falling back to Google-managed encryption:

```hcl
module "craftedsignal" {
  source = "git::https://github.com/CraftedSignal/terraform.git//gcp/modules/platform?ref=gcp/v0.2.0"

  project_id              = var.project_id
  app_domain              = var.app_domain
  gke_rbac_security_group = var.gke_rbac_security_group

  kms = {
    create                   = false
    gke_key_id               = google_kms_crypto_key.gke.id
    cloudsql_key_id          = google_kms_crypto_key.cloudsql.id
    secrets_key_id           = google_kms_crypto_key.secret_manager.id
    artifact_registry_key_id = google_kms_crypto_key.artifact_registry.id
    platform_kek_key_id      = google_kms_crypto_key.platform_kek.id
    attestor_key_id          = google_kms_crypto_key.binauthz_attestor.id
    attestor_key_version     = 1
  }
}
```

## Customer Project Grant

In the customer's KMS project:

```hcl
resource "google_kms_crypto_key_iam_member" "craftedsignal_attested_decrypt" {
  crypto_key_id = google_kms_crypto_key.customer_platform_kek.id
  role          = "roles/cloudkms.cryptoKeyDecrypter"
  member        = "principalSet://iam.googleapis.com/${module.craftedsignal.confidential_space_workload_identity_pool_name}/*"
}
```

The provider condition in the CraftedSignal project always checks the Confidential Space image, the stable support attribute, the expected project number, and the key-broker service account. For production customer-key grants, also set either image digests or image-signing key fingerprints.

When the customer wants the IAM binding itself to name a specific workload image, grant the role to the mapped image-digest attribute instead of the whole pool:

```hcl
resource "google_kms_crypto_key_iam_member" "craftedsignal_digest_decrypt" {
  crypto_key_id = google_kms_crypto_key.customer_platform_kek.id
  role          = "roles/cloudkms.cryptoKeyDecrypter"
  member        = "principalSet://iam.googleapis.com/${module.craftedsignal.confidential_space_workload_identity_pool_name}/attribute.image_digest/sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
}
```

Use `roles/cloudkms.cryptoKeyEncrypterDecrypter` when the key broker must wrap newly generated tenant DEKs with the customer key. Use `roles/cloudkms.cryptoKeyDecrypter` only for a deliberately decrypt-only path where wrapping happens elsewhere.

## Rotation and Operations

Plan key operations as part of the deployment process:

- Rotate infrastructure CMEK keys on the normal Cloud KMS rotation schedule.
- Rotate the application KEK by creating or selecting a new key version, then re-wrapping tenant DEKs. Re-wrapping tenant DEKs does not require re-encrypting tenant content.
- Keep old KEK versions enabled until every tenant DEK wrapped by that version has been re-wrapped and verified.
- Update Confidential Space `allowed_image_digests` or `signing_key_fingerprints` before deploying a workload that needs customer-key access.
- Keep Binary Authorization attestor key versions aligned with the manual deployment workflow that signs image digests.
- Export Cloud KMS audit logs, Workload Identity Federation audit logs, Binary Authorization decisions, and application audit logs to the customer's SIEM or evidence archive.

Expected failure modes should fail closed: a workload that does not match the attestation condition cannot get a federated identity; a workflow that deploys an unattested image is blocked when Binary Authorization enforcement is enabled; and a runtime without KEK access cannot unwrap tenant DEKs.
