module "craftedsignal" {
  source = "../../modules/platform"

  project_id = var.project_id
  region     = var.region
  app_domain = var.app_domain

  labels = var.labels

  gke = {
    master_authorized_networks = var.master_authorized_networks
  }

  artifact_registry_writer_members = var.artifact_registry_writer_members
}

