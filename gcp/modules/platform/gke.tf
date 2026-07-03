resource "google_container_cluster" "main" {
  name     = local.cluster_name
  location = var.region
  project  = var.project_id

  enable_autopilot    = true
  deletion_protection = var.gke.deletion_protection

  network    = local.network_id
  subnetwork = local.subnetwork_id

  ip_allocation_policy {
    cluster_secondary_range_name  = local.pods_range_name
    services_secondary_range_name = local.services_range_name
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = var.gke.private_endpoint
    master_ipv4_cidr_block  = var.network.master_cidr
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.gke.master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr
        display_name = cidr_blocks.value.name
      }
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  database_encryption {
    state    = "ENCRYPTED"
    key_name = google_kms_crypto_key.gke.id
  }

  release_channel {
    channel = var.gke.release_channel
  }

  binary_authorization {
    evaluation_mode = var.gke.binary_authorization ? "PROJECT_SINGLETON_POLICY_ENFORCE" : "DISABLED"
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]

    managed_prometheus {
      enabled = var.gke.managed_prometheus
    }
  }

  cost_management_config {
    enabled = true
  }

  maintenance_policy {
    recurring_window {
      start_time = var.gke.maintenance_start_time
      end_time   = var.gke.maintenance_end_time
      recurrence = var.gke.maintenance_recurrence
    }
  }

  node_config {
    service_account = google_service_account.gke_nodes.email
  }

  resource_labels = local.labels

  depends_on = [
    google_project_service.required,
    google_kms_crypto_key_iam_member.gke_encrypt,
    google_binary_authorization_policy.policy,
  ]
}
