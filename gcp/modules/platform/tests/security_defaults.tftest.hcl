mock_provider "google" {}

mock_provider "random" {}

variables {
  project_id              = "craftedsignal-test"
  gke_rbac_security_group = "gke-security-groups@example.com"
}

run "security_defaults" {
  command = plan

  assert {
    condition     = google_container_cluster.main.enable_autopilot
    error_message = "GKE must remain an Autopilot cluster."
  }

  assert {
    condition     = google_container_cluster.main.datapath_provider == "ADVANCED_DATAPATH"
    error_message = "GKE must use Dataplane V2."
  }

  assert {
    condition = alltrue([
      google_container_cluster.main.resource_labels.app == "craftedsignal",
      google_container_cluster.main.resource_labels.environment == "prod",
      google_container_cluster.main.resource_labels.managed_by == "terraform",
    ])
    error_message = "GKE must keep the required production labels."
  }

  assert {
    condition = alltrue([
      length(google_compute_subnetwork.gke[0].log_config) == 1,
      google_compute_subnetwork.gke[0].log_config[0].aggregation_interval == "INTERVAL_10_MIN",
      google_compute_subnetwork.gke[0].log_config[0].flow_sampling > 0,
      google_compute_subnetwork.gke[0].log_config[0].metadata == "EXCLUDE_ALL_METADATA",
    ])
    error_message = "The created GKE subnetwork must keep VPC flow logs enabled."
  }

  assert {
    condition     = google_sql_database_instance.main.database_version == "POSTGRES_18"
    error_message = "Cloud SQL must default to the latest supported PostgreSQL major version."
  }

  assert {
    condition = alltrue([
      !google_sql_database_instance.main.settings[0].ip_configuration[0].ipv4_enabled,
      google_sql_database_instance.main.settings[0].ip_configuration[0].ssl_mode == "TRUSTED_CLIENT_CERTIFICATE_REQUIRED",
    ])
    error_message = "Cloud SQL must stay private and require trusted client certificates by default."
  }
}

run "reject_disabled_flow_logs" {
  command = plan

  variables {
    network = {
      enable_flow_logs = false
    }
  }

  expect_failures = [
    var.network,
  ]
}

run "reject_disabled_binary_authorization" {
  command = plan

  variables {
    gke = {
      binary_authorization = false
    }
  }

  expect_failures = [
    var.gke,
  ]
}
