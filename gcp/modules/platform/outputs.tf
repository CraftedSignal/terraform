output "project_id" {
  description = "GCP project ID."
  value       = var.project_id
}

output "region" {
  description = "Primary GCP region."
  value       = var.region
}

output "network_name" {
  description = "VPC network name."
  value       = local.network_name_effective
}

output "network_id" {
  description = "VPC network ID."
  value       = local.network_id
}

output "subnetwork_name" {
  description = "GKE subnetwork name."
  value       = local.subnetwork_name_effective
}

output "subnetwork_id" {
  description = "GKE subnetwork ID."
  value       = local.subnetwork_id
}

output "nat_egress_ip" {
  description = "Static Cloud NAT egress IP, if Cloud NAT is enabled."
  value       = try(google_compute_address.nat_egress[0].address, null)
}

output "cluster_name" {
  description = "GKE Autopilot cluster name."
  value       = google_container_cluster.main.name
}

output "cluster_location" {
  description = "GKE cluster location."
  value       = google_container_cluster.main.location
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint."
  value       = google_container_cluster.main.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "GKE cluster CA certificate."
  value       = google_container_cluster.main.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "workload_identity_pool" {
  description = "GKE Workload Identity pool."
  value       = "${var.project_id}.svc.id.goog"
}

output "service_account_emails" {
  description = "Runtime and node service account emails."
  value = {
    gke_nodes = local.gke_node_service_account_email
    app       = local.runtime_service_account_emails.app
    worker    = local.runtime_service_account_emails.worker
    temporal  = local.runtime_service_account_emails.temporal
  }
}

output "cloudsql_instance_name" {
  description = "Cloud SQL instance name."
  value       = google_sql_database_instance.main.name
}

output "cloudsql_instance_connection_name" {
  description = "Cloud SQL instance connection name for Cloud SQL connector or proxy."
  value       = google_sql_database_instance.main.connection_name
}

output "cloudsql_private_ip_address" {
  description = "Cloud SQL private IP address."
  value       = google_sql_database_instance.main.private_ip_address
}

output "database_names" {
  description = "Created PostgreSQL database names."
  value = {
    app                 = google_sql_database.app.name
    temporal            = google_sql_database.temporal.name
    temporal_visibility = google_sql_database.temporal_visibility.name
  }
}

output "database_iam_users" {
  description = "Cloud SQL IAM database usernames corresponding to runtime service accounts."
  value       = local.runtime_database_iam_users
}

output "artifact_registry_repository" {
  description = "Artifact Registry Docker repository metadata, if created."
  value = var.artifact_registry.create ? {
    id  = google_artifact_registry_repository.containers[0].id
    url = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.containers[0].repository_id}"
  } : null
}

output "kms_key_ids" {
  description = "KMS key IDs."
  value = {
    gke               = local.gke_kms_key_id
    cloudsql          = local.cloudsql_kms_key_id
    secrets           = local.secrets_kms_key_id
    artifact_registry = local.artifact_registry_kms_key_id
    attestor          = try(google_kms_crypto_key.attestor[0].id, null)
  }
}

output "secret_ids" {
  description = "Secret Manager placeholder secret IDs created by the module."
  value       = { for name, secret in google_secret_manager_secret.managed : name => secret.id }
}

output "database_password_secret_ids" {
  description = "Secret Manager IDs for generated database passwords when cloudsql.create_password_users is true."
  value       = { for name, secret in google_secret_manager_secret.db_passwords : name => secret.id }
}

output "cloud_armor_security_policy_name" {
  description = "Cloud Armor security policy name for GKE BackendConfig."
  value       = try(google_compute_security_policy.app[0].name, null)
}

output "recaptcha_site_key" {
  description = "reCAPTCHA Enterprise site key name, if created."
  value       = try(google_recaptcha_enterprise_key.app[0].name, null)
}

output "binary_authorization_attestor_name" {
  description = "Binary Authorization attestor name, if Binary Authorization is enabled."
  value       = try(google_binary_authorization_attestor.build[0].name, null)
}

output "binary_authorization_attestor_kms_key_version" {
  description = "KMS key version used by the Binary Authorization attestor."
  value       = try(google_kms_crypto_key_version.attestor[0].id, null)
}

output "binary_authorization_attestor_note_id" {
  description = "Container Analysis note ID used by the Binary Authorization attestor."
  value       = try(google_container_analysis_note.attestor[0].id, null)
}
