variable "project_id" {
  description = "GCP project ID that will host the CraftedSignal production infrastructure."
  type        = string
}

variable "region" {
  description = "Primary GCP region for regional resources."
  type        = string
  default     = "europe-west1"
}

variable "name" {
  description = "Short deployment name used as a resource prefix."
  type        = string
  default     = "craftedsignal"
}

variable "environment" {
  description = "Environment label. This module is intended for production deployments; default is prod."
  type        = string
  default     = "prod"
}

variable "app_domain" {
  description = "Public application domain, used for Cloud Armor/reCAPTCHA metadata and examples. Leave empty if DNS/LB is managed outside this module."
  type        = string
  default     = ""
}

variable "labels" {
  description = "Additional labels applied to supported GCP resources."
  type        = map(string)
  default     = {}
}

variable "enable_project_services" {
  description = "Enable required GCP APIs in the target project."
  type        = bool
  default     = true
}

variable "extra_project_services" {
  description = "Additional GCP APIs to enable."
  type        = list(string)
  default     = []
}

variable "network" {
  description = "Production VPC configuration. Set create=false to use an existing VPC and subnetwork by name."
  type = object({
    create                               = optional(bool, true)
    network_name                         = optional(string)
    subnetwork_name                      = optional(string)
    subnet_cidr                          = optional(string, "10.10.0.0/20")
    pods_cidr                            = optional(string, "10.20.0.0/14")
    services_cidr                        = optional(string, "10.24.0.0/20")
    pods_range_name                      = optional(string, "pods")
    services_range_name                  = optional(string, "services")
    master_cidr                          = optional(string, "172.16.0.0/28")
    private_service_access_prefix_length = optional(number, 16)
    enable_cloud_nat                     = optional(bool, true)
    enable_dns_logging                   = optional(bool, true)
    enable_flow_logs                     = optional(bool, true)
    flow_logs_sampling                   = optional(number, 0.01)
  })
  default = {}

  validation {
    condition = (
      try(var.network.create, true) ||
      (try(var.network.network_name, null) != null && try(var.network.subnetwork_name, null) != null)
    )
    error_message = "When network.create is false, network.network_name and network.subnetwork_name are required."
  }

  validation {
    condition     = var.network.enable_flow_logs
    error_message = "network.enable_flow_logs must remain true for production deployments."
  }
}

variable "service_account_ids" {
  description = "GCP service account IDs. Keep each value within GCP's 30-character account_id limit."
  type = object({
    gke_nodes = optional(string, "craftedsignal-prod-gke")
    app       = optional(string, "craftedsignal-prod-app")
    worker    = optional(string, "craftedsignal-prod-worker")
    temporal  = optional(string, "craftedsignal-prod-temporal")
  })
  default = {}
}

variable "workload_identity" {
  description = "Kubernetes service accounts bound to GCP service accounts through GKE Workload Identity."
  type = object({
    enable_bindings          = optional(bool, true)
    app_namespace            = optional(string, "craftedsignal")
    app_service_account      = optional(string, "craftedsignal")
    worker_namespace         = optional(string, "craftedsignal")
    worker_service_account   = optional(string, "craftedsignal-worker")
    temporal_namespace       = optional(string, "temporal-system")
    temporal_service_account = optional(string, "temporal")
  })
  default = {}
}

variable "gke_rbac_security_group" {
  description = "Google Groups for GKE security group used for Kubernetes RBAC user and group bindings. Must be named gke-security-groups@<domain>."
  type        = string

  validation {
    condition     = can(regex("^gke-security-groups@[^@]+\\.[^@]+$", var.gke_rbac_security_group))
    error_message = "gke_rbac_security_group must look like gke-security-groups@example.com."
  }
}

variable "gke" {
  description = "GKE Autopilot production cluster settings."
  type = object({
    cluster_name               = optional(string)
    release_channel            = optional(string, "REGULAR")
    deletion_protection        = optional(bool, true)
    private_endpoint           = optional(bool, false)
    binary_authorization       = optional(bool, true)
    managed_prometheus         = optional(bool, true)
    master_authorized_networks = optional(list(object({ cidr = string, name = string })), [])
    maintenance_start_time     = optional(string, "2024-01-06T02:00:00Z")
    maintenance_end_time       = optional(string, "2024-01-06T06:00:00Z")
    maintenance_recurrence     = optional(string, "FREQ=WEEKLY;BYDAY=SA,SU")
  })
  default = {}

  validation {
    condition     = var.gke.binary_authorization
    error_message = "gke.binary_authorization must remain true for production deployments."
  }
}

variable "cloudsql" {
  description = "Cloud SQL PostgreSQL production settings."
  type = object({
    instance_name                     = optional(string)
    tier                              = optional(string, "db-custom-2-7680")
    availability_type                 = optional(string, "REGIONAL")
    disk_size                         = optional(number, 100)
    disk_autoresize_limit             = optional(number, 1000)
    deletion_protection               = optional(bool, true)
    retained_backups                  = optional(number, 30)
    backup_start_time                 = optional(string, "03:00")
    maintenance_day                   = optional(number, 7)
    maintenance_hour                  = optional(number, 3)
    enable_iam_authentication         = optional(bool, true)
    create_password_users             = optional(bool, false)
    app_database_name                 = optional(string, "craftedsignal")
    temporal_database_name            = optional(string, "temporal")
    temporal_visibility_database_name = optional(string, "temporal_visibility")
    app_password_user                 = optional(string, "craftedsignal")
    temporal_password_user            = optional(string, "temporal")
    database_flags                    = optional(map(string), {})
  })
  default = {}

  validation {
    condition = length(setintersection(toset(keys(var.cloudsql.database_flags)), toset([
      "cloudsql.enable_pgaudit",
      "cloudsql.iam_authentication",
      "log_checkpoints",
      "log_connections",
      "log_disconnections",
      "log_duration",
      "log_error_verbosity",
      "log_hostname",
      "log_lock_waits",
      "log_min_duration_statement",
      "log_min_error_statement",
      "log_min_messages",
      "log_statement",
    ]))) == 0
    error_message = "cloudsql.database_flags cannot override mandatory production logging, audit, or IAM-authentication flags."
  }
}

variable "artifact_registry" {
  description = "Artifact Registry Docker repository configuration."
  type = object({
    create        = optional(bool, true)
    repository_id = optional(string, "craftedsignal")
    description   = optional(string, "CraftedSignal production container images")
  })
  default = {}
}

variable "artifact_registry_writer_members" {
  description = "IAM members granted roles/artifactregistry.writer on the created repository, for example Workload Identity Federation deployers."
  type        = list(string)
  default     = []
}

variable "cloud_armor" {
  description = "Optional Cloud Armor policy for the GKE ingress BackendConfig."
  type = object({
    enabled                   = optional(bool, true)
    policy_name               = optional(string)
    recaptcha_enabled         = optional(bool, true)
    recaptcha_enforcement     = optional(bool, false)
    recaptcha_score_threshold = optional(number, 0.3)
    waf_preview               = optional(bool, true)
    login_rate_limit_count    = optional(number, 20)
    login_rate_limit_window   = optional(number, 60)
  })
  default = {}
}

variable "secrets" {
  description = "Secret Manager placeholder secrets created for deployment-time configuration. Secret versions should be written outside Terraform unless intentionally managed as state."
  type = object({
    create     = optional(bool, true)
    secret_ids = optional(list(string), ["craftedsignal-master-secret", "craftedsignal-license-key", "craftedsignal-config"])
    access = optional(map(list(string)), {
      app      = ["craftedsignal-master-secret", "craftedsignal-license-key", "craftedsignal-config"]
      worker   = ["craftedsignal-master-secret", "craftedsignal-license-key", "craftedsignal-config"]
      temporal = []
    })
  })
  default = {}
}

variable "binary_authorization" {
  description = "Binary Authorization policy, attestor, and attestation writer settings."
  type = object({
    enforcement_mode           = optional(string, "DRYRUN_AUDIT_LOG_ONLY")
    attestor_name              = optional(string)
    note_name                  = optional(string)
    attestation_writer_members = optional(list(string), [])
    admission_whitelist_patterns = optional(list(string), [
      "gke.gcr.io/*",
      "gcr.io/gke-release/*",
      "gcr.io/config-management-release/*",
      "gcr.io/cloud-provider-vsphere/*",
      "gcr.io/gkeconnect/*",
      "gcr.io/gke-multi-cloud-release/*",
      "gcr.io/kubebuilder/*",
      "europe-west1-docker.pkg.dev/gke-release/*",
      "europe-west4-docker.pkg.dev/gke-release/*",
      "us-central1-docker.pkg.dev/gke-release/*",
      "us-east1-docker.pkg.dev/gke-release/*",
    ])
  })
  default = {}

  validation {
    condition     = contains(["DRYRUN_AUDIT_LOG_ONLY", "ENFORCED_BLOCK_AND_AUDIT_LOG"], var.binary_authorization.enforcement_mode)
    error_message = "binary_authorization.enforcement_mode must be DRYRUN_AUDIT_LOG_ONLY or ENFORCED_BLOCK_AND_AUDIT_LOG."
  }
}
