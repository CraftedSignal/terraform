resource "google_kms_key_ring" "main" {
  count = local.create_kms_keys ? 1 : 0

  name     = local.resource_prefix
  location = var.region
  project  = var.project_id

  depends_on = [google_project_service.required]
}

resource "google_kms_crypto_key" "gke" {
  count = local.create_kms_keys ? 1 : 0

  name            = "gke-secrets"
  key_ring        = google_kms_key_ring.main[0].id
  rotation_period = "7776000s"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key" "cloudsql" {
  count = local.create_kms_keys ? 1 : 0

  name            = "cloudsql"
  key_ring        = google_kms_key_ring.main[0].id
  rotation_period = "7776000s"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key" "secrets" {
  count = local.create_kms_keys ? 1 : 0

  name            = "secret-manager"
  key_ring        = google_kms_key_ring.main[0].id
  rotation_period = "7776000s"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key" "artifact_registry" {
  count = local.create_kms_keys ? 1 : 0

  name            = "artifact-registry"
  key_ring        = google_kms_key_ring.main[0].id
  rotation_period = "7776000s"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key" "attestor" {
  count = local.create_kms_keys && local.create_binary_authorization_resources ? 1 : 0

  name     = "binary-authorization-attestor"
  key_ring = google_kms_key_ring.main[0].id
  purpose  = "ASYMMETRIC_SIGN"

  version_template {
    algorithm        = "EC_SIGN_P256_SHA256"
    protection_level = "HSM"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key_version" "attestor" {
  count = local.create_kms_keys && local.create_binary_authorization_resources ? 1 : 0

  crypto_key = google_kms_crypto_key.attestor[0].id
}

data "google_kms_crypto_key_version" "attestor_public_key" {
  count = local.create_kms_keys && local.create_binary_authorization_resources ? 1 : 0

  crypto_key = google_kms_crypto_key.attestor[0].id
}

resource "google_kms_crypto_key_iam_member" "gke_encrypt" {
  count = local.create_kms_keys && var.kms.manage_iam ? 1 : 0

  crypto_key_id = local.gke_kms_key_id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_kms_crypto_key_iam_member" "cloudsql_encrypt" {
  count = local.create_kms_keys && var.kms.manage_iam ? 1 : 0

  crypto_key_id = local.cloudsql_kms_key_id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-cloud-sql.iam.gserviceaccount.com"
}

resource "google_kms_crypto_key_iam_member" "secretmanager_encrypt" {
  count = local.create_kms_keys && var.kms.manage_iam ? 1 : 0

  crypto_key_id = local.secrets_kms_key_id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-secretmanager.iam.gserviceaccount.com"
}

resource "google_kms_crypto_key_iam_member" "artifact_registry_encrypt" {
  count = local.create_kms_keys && var.kms.manage_iam ? 1 : 0

  crypto_key_id = local.artifact_registry_kms_key_id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-artifactregistry.iam.gserviceaccount.com"
}
