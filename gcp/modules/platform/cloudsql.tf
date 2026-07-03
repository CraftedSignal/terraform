resource "google_sql_database_instance" "main" {
  name                = local.cloudsql_name
  database_version    = "POSTGRES_18"
  region              = var.region
  project             = var.project_id
  deletion_protection = var.cloudsql.deletion_protection
  encryption_key_name = google_kms_crypto_key.cloudsql.id

  settings {
    tier                  = var.cloudsql.tier
    availability_type     = var.cloudsql.availability_type
    disk_size             = var.cloudsql.disk_size
    disk_type             = "PD_SSD"
    disk_autoresize       = true
    disk_autoresize_limit = var.cloudsql.disk_autoresize_limit

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = var.cloudsql.backup_start_time
      location                       = var.region

      backup_retention_settings {
        retained_backups = var.cloudsql.retained_backups
        retention_unit   = "COUNT"
      }
    }

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = local.network_id
      enable_private_path_for_google_cloud_services = true
      ssl_mode                                      = "TRUSTED_CLIENT_CERTIFICATE_REQUIRED"
    }

    database_flags {
      name  = "cloudsql.enable_pgaudit"
      value = "on"
    }

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = var.cloudsql.enable_iam_authentication ? "on" : "off"
    }

    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }

    database_flags {
      name  = "log_connections"
      value = "on"
    }

    database_flags {
      name  = "log_disconnections"
      value = "on"
    }

    database_flags {
      name  = "log_duration"
      value = "on"
    }

    database_flags {
      name  = "log_error_verbosity"
      value = "default"
    }

    database_flags {
      name  = "log_hostname"
      value = "on"
    }

    database_flags {
      name  = "log_lock_waits"
      value = "on"
    }

    database_flags {
      name  = "log_min_duration_statement"
      value = "-1"
    }

    database_flags {
      name  = "log_min_error_statement"
      value = "error"
    }

    database_flags {
      name  = "log_min_messages"
      value = "error"
    }

    database_flags {
      name  = "log_statement"
      value = "ddl"
    }

    dynamic "database_flags" {
      for_each = var.cloudsql.database_flags
      content {
        name  = database_flags.key
        value = database_flags.value
      }
    }

    maintenance_window {
      day          = var.cloudsql.maintenance_day
      hour         = var.cloudsql.maintenance_hour
      update_track = "stable"
    }

    insights_config {
      query_insights_enabled  = true
      query_plans_per_minute  = 5
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }

    user_labels = local.labels
  }

  depends_on = [
    google_kms_crypto_key_iam_member.cloudsql_encrypt,
    google_service_networking_connection.private_vpc_connection,
  ]
}

resource "google_sql_database" "app" {
  name     = var.cloudsql.app_database_name
  instance = google_sql_database_instance.main.name
  project  = var.project_id
}

resource "google_sql_database" "temporal" {
  name     = var.cloudsql.temporal_database_name
  instance = google_sql_database_instance.main.name
  project  = var.project_id
}

resource "google_sql_database" "temporal_visibility" {
  name     = var.cloudsql.temporal_visibility_database_name
  instance = google_sql_database_instance.main.name
  project  = var.project_id
}

resource "google_sql_user" "iam_service_accounts" {
  for_each = var.cloudsql.enable_iam_authentication ? local.runtime_service_account_emails : {}

  name     = replace(each.value, ".gserviceaccount.com", "")
  instance = google_sql_database_instance.main.name
  project  = var.project_id
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}

resource "random_password" "app_db" {
  count = var.cloudsql.create_password_users ? 1 : 0

  length  = 32
  special = true
}

resource "random_password" "temporal_db" {
  count = var.cloudsql.create_password_users ? 1 : 0

  length  = 32
  special = true
}

resource "google_sql_user" "app_password" {
  count = var.cloudsql.create_password_users ? 1 : 0

  name     = var.cloudsql.app_password_user
  instance = google_sql_database_instance.main.name
  project  = var.project_id
  password = random_password.app_db[0].result
}

resource "google_sql_user" "temporal_password" {
  count = var.cloudsql.create_password_users ? 1 : 0

  name     = var.cloudsql.temporal_password_user
  instance = google_sql_database_instance.main.name
  project  = var.project_id
  password = random_password.temporal_db[0].result
}

resource "google_secret_manager_secret" "db_passwords" {
  for_each = var.cloudsql.create_password_users ? toset(["app", "temporal"]) : toset([])

  secret_id = "${local.resource_prefix}-${each.key}-db-password"
  project   = var.project_id

  replication {
    user_managed {
      replicas {
        location = var.region

        customer_managed_encryption {
          kms_key_name = google_kms_crypto_key.secrets.id
        }
      }
    }
  }

  labels = local.labels

  depends_on = [google_kms_crypto_key_iam_member.secretmanager_encrypt]
}

resource "google_secret_manager_secret_version" "db_passwords" {
  for_each = var.cloudsql.create_password_users ? {
    app      = random_password.app_db[0].result
    temporal = random_password.temporal_db[0].result
  } : {}

  secret      = google_secret_manager_secret.db_passwords[each.key].id
  secret_data = each.value
}
