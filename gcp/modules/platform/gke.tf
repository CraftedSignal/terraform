resource "google_container_cluster" "main" {
  #checkov:skip=CKV_GCP_12:GKE Autopilot uses Dataplane V2 for network policy; Terraform rejects network_policy when enable_autopilot is true.
  #checkov:skip=CKV_GCP_21:Cluster resource_labels merges required labels with caller labels; Checkov does not resolve Terraform merge().
  #checkov:skip=CKV_GCP_61:Subnetwork flow logs are configured explicitly; intranode visibility is not configurable on GKE Autopilot.

  name     = local.cluster_name
  location = var.region
  project  = var.project_id

  enable_autopilot    = true
  deletion_protection = var.gke.deletion_protection
  resource_labels     = local.labels

  network           = local.network_id
  subnetwork        = local.subnetwork_id
  datapath_provider = "ADVANCED_DATAPATH"

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

  authenticator_groups_config {
    security_group = var.gke_rbac_security_group
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  database_encryption {
    state    = "ENCRYPTED"
    key_name = local.gke_kms_key_id
  }

  release_channel {
    channel = var.gke.release_channel
  }

  notification_config {
    pubsub {
      enabled = var.gke.notification_topic_id != ""
      topic   = var.gke.notification_topic_id != "" ? var.gke.notification_topic_id : null

      filter {
        event_type = ["UPGRADE_AVAILABLE_EVENT", "UPGRADE_EVENT", "SECURITY_BULLETIN_EVENT"]
      }
    }
  }

  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
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
    service_account = local.gke_node_service_account_email

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }

  depends_on = [
    google_project_service.required,
    google_kms_crypto_key_iam_member.gke_encrypt,
    google_binary_authorization_policy.policy,
  ]
}
