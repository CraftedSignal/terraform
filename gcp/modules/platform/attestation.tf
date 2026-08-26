resource "google_iam_workload_identity_pool" "confidential_space" {
  count = local.confidential_space_attestation_enabled ? 1 : 0

  project                   = var.project_id
  workload_identity_pool_id = local.confidential_space_workload_identity_pool_id
  display_name              = "Confidential Space Attestation"
  description               = "Attested identity pool for application-level encryption key access."

  depends_on = [google_project_service.required]
}

resource "google_iam_workload_identity_pool_provider" "confidential_space" {
  count = local.confidential_space_attestation_enabled ? 1 : 0

  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.confidential_space[0].workload_identity_pool_id
  workload_identity_pool_provider_id = local.confidential_space_workload_identity_provider_id
  display_name                       = "Confidential Space"
  description                        = "Accepts tokens only from stable Confidential Space workloads matching the configured image, signature, or service-account policy."

  attribute_mapping = {
    "google.subject"           = "\"gcpcs::\" + assertion.submods.gce.project_number + \"::\" + assertion.submods.gce.instance_id"
    "attribute.image_digest"   = "has(assertion.submods.container.image_digest) ? assertion.submods.container.image_digest : \"\""
    "attribute.project_number" = "assertion.submods.gce.project_number"
  }

  attribute_condition = local.confidential_space_attestation_condition

  oidc {
    issuer_uri        = local.confidential_space_attestation.issuer_uri
    allowed_audiences = ["https://sts.googleapis.com"]
  }
}

resource "google_kms_crypto_key_iam_member" "platform_kek_confidential_space_decrypter" {
  count = (
    local.confidential_space_attestation_enabled &&
    local.confidential_space_attestation.grant_platform_kek_decrypt
  ) ? 1 : 0

  crypto_key_id = local.platform_kek_kms_key_id
  role          = "roles/cloudkms.cryptoKeyDecrypter"
  member        = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.confidential_space[0].name}/*"
}
