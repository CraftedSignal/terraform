resource "google_secret_manager_secret" "managed" {
  for_each = local.managed_secret_ids

  secret_id = each.key
  project   = var.project_id

  replication {
    user_managed {
      replicas {
        location = var.region

        customer_managed_encryption {
          kms_key_name = local.secrets_kms_key_id
        }
      }
    }
  }

  labels = local.labels

  depends_on = [google_kms_crypto_key_iam_member.secretmanager_encrypt]
}

resource "google_secret_manager_secret_iam_member" "runtime_secret_access" {
  for_each = local.runtime_secret_access_bindings

  project   = var.project_id
  secret_id = google_secret_manager_secret.managed[each.value.secret_id].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${each.value.service_account}"
}

resource "google_secret_manager_secret_iam_member" "db_password_access" {
  for_each = var.cloudsql.create_password_users ? {
    app      = local.runtime_service_account_emails.app
    worker   = local.runtime_service_account_emails.worker
    temporal = local.runtime_service_account_emails.temporal
  } : {}

  project = var.project_id
  secret_id = each.key == "temporal" ? (
    google_secret_manager_secret.db_passwords["temporal"].secret_id
    ) : (
    google_secret_manager_secret.db_passwords["app"].secret_id
  )
  role   = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${each.value}"
}
