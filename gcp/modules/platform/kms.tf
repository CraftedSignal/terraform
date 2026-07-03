resource "google_kms_key_ring" "main" {
  name     = local.resource_prefix
  location = var.region
  project  = var.project_id

  depends_on = [google_project_service.required]
}

resource "google_kms_crypto_key" "gke" {
  name            = "gke-secrets"
  key_ring        = google_kms_key_ring.main.id
  rotation_period = "7776000s"
}

resource "google_kms_crypto_key" "cloudsql" {
  name            = "cloudsql"
  key_ring        = google_kms_key_ring.main.id
  rotation_period = "7776000s"
}

resource "google_kms_crypto_key" "secrets" {
  name            = "secret-manager"
  key_ring        = google_kms_key_ring.main.id
  rotation_period = "7776000s"
}

resource "google_kms_crypto_key_iam_member" "gke_encrypt" {
  crypto_key_id = google_kms_crypto_key.gke.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_kms_crypto_key_iam_member" "cloudsql_encrypt" {
  crypto_key_id = google_kms_crypto_key.cloudsql.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-cloud-sql.iam.gserviceaccount.com"
}

resource "google_kms_crypto_key_iam_member" "secretmanager_encrypt" {
  crypto_key_id = google_kms_crypto_key.secrets.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-secretmanager.iam.gserviceaccount.com"
}

