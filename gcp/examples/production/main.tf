module "craftedsignal" {
  source = "../../modules/platform"

  project_id = var.project_id
  region     = var.region
  app_domain = var.app_domain

  labels = var.labels

  gke_rbac_security_group = var.gke_rbac_security_group

  gke = {
    master_authorized_networks = var.master_authorized_networks
    confidential_nodes         = var.enable_confidential_gke_nodes
  }

  application_encryption = {
    confidential_space_attestation = {
      enabled                    = var.enable_confidential_space_attestation
      allowed_image_digests      = var.confidential_space_allowed_image_digests
      signing_key_fingerprints   = var.confidential_space_signing_key_fingerprints
      grant_platform_kek_decrypt = false
    }
  }

  artifact_registry_writer_members = var.artifact_registry_writer_members
}
