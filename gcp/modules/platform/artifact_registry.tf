resource "google_artifact_registry_repository" "containers" {
  count = var.artifact_registry.create ? 1 : 0

  project       = var.project_id
  location      = var.region
  repository_id = var.artifact_registry.repository_id
  description   = var.artifact_registry.description
  format        = "DOCKER"
  kms_key_name  = google_kms_crypto_key.artifact_registry.id
  labels        = local.labels

  depends_on = [
    google_kms_crypto_key_iam_member.artifact_registry_encrypt,
    google_project_service.required,
  ]
}

resource "google_artifact_registry_repository_iam_member" "gke_reader" {
  count = var.artifact_registry.create ? 1 : 0

  project    = var.project_id
  location   = google_artifact_registry_repository.containers[0].location
  repository = google_artifact_registry_repository.containers[0].repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_artifact_registry_repository_iam_member" "writers" {
  for_each = var.artifact_registry.create ? toset(var.artifact_registry_writer_members) : toset([])

  project    = var.project_id
  location   = google_artifact_registry_repository.containers[0].location
  repository = google_artifact_registry_repository.containers[0].repository_id
  role       = "roles/artifactregistry.writer"
  member     = each.key
}
