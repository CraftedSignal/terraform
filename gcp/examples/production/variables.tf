variable "project_id" {
  description = "GCP project ID for the production deployment."
  type        = string
}

variable "region" {
  description = "GCP region."
  type        = string
  default     = "europe-west1"
}

variable "app_domain" {
  description = "Public application domain."
  type        = string
}

variable "gke_rbac_security_group" {
  description = "Google Groups for GKE security group, usually gke-security-groups@<workspace-domain>."
  type        = string
}

variable "master_authorized_networks" {
  description = "CIDRs allowed to access the public GKE control-plane endpoint."
  type        = list(object({ cidr = string, name = string }))
  default     = []
}

variable "artifact_registry_writer_members" {
  description = "IAM members allowed to push production images."
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Additional labels."
  type        = map(string)
  default     = {}
}
