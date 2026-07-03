resource "google_service_account" "gke_nodes" {
  count = local.create_service_accounts ? 1 : 0

  account_id   = var.service_account_ids.gke_nodes
  display_name = "CraftedSignal GKE nodes"
  description  = "Node service account for the CraftedSignal production GKE cluster."
  project      = var.project_id

  depends_on = [google_project_service.required]
}

resource "google_service_account" "runtime" {
  for_each = local.create_service_accounts ? local.runtime_service_account_config : {}

  account_id   = each.value.account_id
  display_name = each.value.display_name
  description  = "Runtime service account for ${each.value.display_name}."
  project      = var.project_id

  depends_on = [google_project_service.required]
}

resource "google_project_iam_member" "gke_node_roles" {
  for_each = local.manage_service_account_iam ? toset([
    "roles/artifactregistry.reader",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
  ]) : toset([])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${local.gke_node_service_account_email}"
}

resource "google_project_iam_member" "runtime_roles" {
  for_each = local.manage_service_account_iam ? local.runtime_project_role_bindings : {}

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${local.runtime_service_account_emails[each.value.service]}"
}

resource "google_service_account_iam_member" "workload_identity" {
  for_each = var.workload_identity.enable_bindings && local.manage_service_account_iam ? local.workload_identity_bindings : {}

  service_account_id = local.runtime_service_account_names[each.key]
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${each.value.namespace}/${each.value.service_account}]"
}
