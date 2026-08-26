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

variable "enable_confidential_gke_nodes" {
  description = "Enable Confidential GKE Nodes. This is a cluster creation-time setting; turn it on for new clusters or planned cutovers."
  type        = bool
  default     = false
}

variable "enable_confidential_space_attestation" {
  description = "Create a Confidential Space Workload Identity provider for attested application-encryption key access."
  type        = bool
  default     = false
}

variable "confidential_space_allowed_image_digests" {
  description = "Container image digests allowed by the Confidential Space attestation provider, as lower-case sha256:<64 hex> values."
  type        = list(string)
  default     = []
}

variable "confidential_space_signing_key_fingerprints" {
  description = "SHA-256 public-key fingerprints accepted in Confidential Space image-signature attestations."
  type        = list(string)
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
