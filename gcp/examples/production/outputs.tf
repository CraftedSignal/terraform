output "cluster_name" {
  description = "GKE cluster name."
  value       = module.craftedsignal.cluster_name
}

output "cloudsql_instance_connection_name" {
  description = "Cloud SQL connection name for the app config."
  value       = module.craftedsignal.cloudsql_instance_connection_name
}

output "cloudsql_private_ip_address" {
  description = "Cloud SQL private IP address."
  value       = module.craftedsignal.cloudsql_private_ip_address
}

output "database_iam_users" {
  description = "IAM database users that need PostgreSQL schema grants."
  value       = module.craftedsignal.database_iam_users
}

output "artifact_registry_repository" {
  description = "Artifact Registry repository URL."
  value       = module.craftedsignal.artifact_registry_repository
}

output "service_account_emails" {
  description = "Runtime GCP service account emails."
  value       = module.craftedsignal.service_account_emails
}

output "cloud_armor_security_policy_name" {
  description = "Cloud Armor policy name for GKE BackendConfig."
  value       = module.craftedsignal.cloud_armor_security_policy_name
}

