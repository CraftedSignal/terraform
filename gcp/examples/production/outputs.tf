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

output "platform_kek_kms_key_id" {
  description = "Cloud KMS key ID for wrapping CraftedSignal tenant data-encryption keys."
  value       = module.craftedsignal.platform_kek_kms_key_id
}

output "key_broker_service_account_email" {
  description = "Application encryption key-broker GCP service account."
  value       = module.craftedsignal.key_broker_service_account_email
}

output "confidential_space_workload_identity_pool_name" {
  description = "Confidential Space Workload Identity Pool name for customer KMS IAM grants."
  value       = module.craftedsignal.confidential_space_workload_identity_pool_name
}

output "confidential_space_workload_identity_provider_name" {
  description = "Confidential Space Workload Identity Provider name for attested key access."
  value       = module.craftedsignal.confidential_space_workload_identity_provider_name
}
