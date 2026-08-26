mock_provider "google" {
  override_during = plan

  mock_data "google_project" {
    defaults = {
      number = "123456789012"
    }
  }

  mock_data "google_kms_crypto_key_version" {
    defaults = {
      id = "projects/craftedsignal-test/locations/europe-west1/keyRings/customer/cryptoKeys/binauthz-attestor/cryptoKeyVersions/1"
      public_key = [
        {
          algorithm = "EC_SIGN_P256_SHA256"
          pem       = "-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE+4w7RkzJm8gdfcQGNw3kgpfkVmCD\n6H2ypRb3d8BIy+6iQriEwVfZk3jqZ7SILUJdQ6S8W6yZf7EHTZ1L0Ir6AQ==\n-----END PUBLIC KEY-----"
        }
      ]
    }
  }
}

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
      google_kms_crypto_key.gke[0].version_template[0].protection_level == "HSM",
      google_kms_crypto_key.cloudsql[0].version_template[0].protection_level == "HSM",
      google_kms_crypto_key.secrets[0].version_template[0].protection_level == "HSM",
      google_kms_crypto_key.artifact_registry[0].version_template[0].protection_level == "HSM",
      google_kms_crypto_key.platform_kek[0].version_template[0].protection_level == "HSM",
      google_kms_crypto_key.attestor[0].version_template[0].protection_level == "HSM",
    ])
    error_message = "KMS encryption keys must stay HSM-backed."
  }

  assert {
    condition = alltrue([
      google_kms_crypto_key.platform_kek[0].name == "platform-kek",
      google_kms_crypto_key.platform_kek[0].purpose == "ENCRYPT_DECRYPT",
    ])
    error_message = "The application encryption platform KEK must exist and support envelope encryption."
  }

  assert {
    condition     = length(google_kms_crypto_key_iam_member.platform_runtime_encrypt) == 0
    error_message = "Runtime service accounts must not get direct platform KEK access unless explicitly enabled."
  }

  assert {
    condition     = google_kms_crypto_key_iam_member.platform_key_broker_decrypt[0].role == "roles/cloudkms.cryptoKeyEncrypterDecrypter"
    error_message = "The key broker must be able to wrap and unwrap tenant DEKs by default."
  }

  assert {
    condition     = google_binary_authorization_policy.policy[0].default_admission_rule[0].enforcement_mode == "ENFORCED_BLOCK_AND_AUDIT_LOG"
    error_message = "Binary Authorization must block unsigned production images by default."
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

run "confidential_nodes_enabled" {
  command = plan

  variables {
    gke = {
      confidential_nodes = true
    }
  }

  assert {
    condition     = google_container_cluster.main.confidential_nodes[0].enabled
    error_message = "GKE confidential nodes should be enabled when requested."
  }
}

run "confidential_space_attestation" {
  command = plan

  variables {
    application_encryption = {
      create_key_broker_service_account = false
      key_broker_service_account_email  = "cs-key-broker@craftedsignal-test.iam.gserviceaccount.com"
      confidential_space_attestation = {
        enabled = true
        allowed_image_digests = [
          "sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        ]
      }
    }
  }

  assert {
    condition     = google_iam_workload_identity_pool.confidential_space[0].workload_identity_pool_id == "craftedsignal-prod-attest"
    error_message = "Confidential Space attestation must create the expected workload identity pool."
  }

  assert {
    condition     = strcontains(local.confidential_space_attestation_condition, "sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef")
    error_message = "Confidential Space provider must restrict configured image digests."
  }
}

run "adopt_existing_kms_keys" {
  command = plan

  variables {
    kms = {
      create                   = false
      gke_key_id               = "projects/craftedsignal-test/locations/europe-west1/keyRings/customer/cryptoKeys/gke-secrets"
      cloudsql_key_id          = "projects/craftedsignal-test/locations/europe-west1/keyRings/customer/cryptoKeys/cloudsql"
      secrets_key_id           = "projects/craftedsignal-test/locations/europe-west1/keyRings/customer/cryptoKeys/secret-manager"
      artifact_registry_key_id = "projects/craftedsignal-test/locations/europe-west1/keyRings/customer/cryptoKeys/artifact-registry"
      platform_kek_key_id      = "projects/craftedsignal-test/locations/europe-west1/keyRings/customer/cryptoKeys/platform-kek"
      attestor_key_id          = "projects/craftedsignal-test/locations/europe-west1/keyRings/customer/cryptoKeys/binauthz-attestor"
      attestor_key_version     = 1
    }
  }

  assert {
    condition     = length(google_kms_crypto_key.gke) == 0
    error_message = "KMS adoption mode must not create managed encryption keys."
  }

  assert {
    condition     = local.binary_authorization_attestor_kms_key_id == "projects/craftedsignal-test/locations/europe-west1/keyRings/customer/cryptoKeys/binauthz-attestor"
    error_message = "Binary Authorization should use the supplied attestor KMS key when KMS keys are adopted."
  }
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
