data "google_project" "current" {
  project_id = var.project_id
}

resource "google_project_service" "required" {
  for_each = var.enable_project_services ? local.project_services : toset([])

  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

