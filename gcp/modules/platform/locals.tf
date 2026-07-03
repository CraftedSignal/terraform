locals {
  resource_prefix = "${var.name}-${var.environment}"

  labels = merge(
    {
      app         = var.name
      environment = var.environment
      managed_by  = "terraform"
    },
    var.labels
  )

  base_project_services = [
    "artifactregistry.googleapis.com",
    "binaryauthorization.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudtrace.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containeranalysis.googleapis.com",
    "dns.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
  ]

  project_services = toset(concat(
    local.base_project_services,
    var.cloud_armor.enabled && var.cloud_armor.recaptcha_enabled ? ["recaptchaenterprise.googleapis.com"] : [],
    var.extra_project_services
  ))

  network_name    = coalesce(var.network.network_name, "${local.resource_prefix}-vpc")
  subnetwork_name = coalesce(var.network.subnetwork_name, "${local.resource_prefix}-gke")

  created_network_id          = try(google_compute_network.main[0].id, null)
  created_network_name        = try(google_compute_network.main[0].name, null)
  created_subnetwork_id       = try(google_compute_subnetwork.gke[0].id, null)
  created_subnetwork_name     = try(google_compute_subnetwork.gke[0].name, null)
  created_pods_range_name     = try(google_compute_subnetwork.gke[0].secondary_ip_range[0].range_name, null)
  created_services_range_name = try(google_compute_subnetwork.gke[0].secondary_ip_range[1].range_name, null)

  existing_network_id          = try(data.google_compute_network.existing[0].id, null)
  existing_network_name        = try(data.google_compute_network.existing[0].name, null)
  existing_subnetwork_id       = try(data.google_compute_subnetwork.existing[0].id, null)
  existing_subnetwork_name     = try(data.google_compute_subnetwork.existing[0].name, null)
  existing_pods_range_name     = var.network.pods_range_name
  existing_services_range_name = var.network.services_range_name

  network_id                = var.network.create ? local.created_network_id : local.existing_network_id
  network_name_effective    = var.network.create ? local.created_network_name : local.existing_network_name
  subnetwork_id             = var.network.create ? local.created_subnetwork_id : local.existing_subnetwork_id
  subnetwork_name_effective = var.network.create ? local.created_subnetwork_name : local.existing_subnetwork_name
  pods_range_name           = var.network.create ? local.created_pods_range_name : local.existing_pods_range_name
  services_range_name       = var.network.create ? local.created_services_range_name : local.existing_services_range_name

  cluster_name      = coalesce(var.gke.cluster_name, local.resource_prefix)
  cloudsql_name     = coalesce(var.cloudsql.instance_name, local.resource_prefix)
  cloud_armor_name  = coalesce(var.cloud_armor.policy_name, "${local.resource_prefix}-waf")
  recaptcha_enabled = var.cloud_armor.enabled && var.cloud_armor.recaptcha_enabled && var.app_domain != ""

  runtime_service_account_config = {
    app = {
      account_id   = var.service_account_ids.app
      display_name = "CraftedSignal application"
    }
    worker = {
      account_id   = var.service_account_ids.worker
      display_name = "CraftedSignal worker"
    }
    temporal = {
      account_id   = var.service_account_ids.temporal
      display_name = "CraftedSignal Temporal"
    }
  }

  runtime_service_account_emails = {
    for name, account in google_service_account.runtime :
    name => account.email
  }

  runtime_database_iam_users = {
    for name, email in local.runtime_service_account_emails :
    name => replace(email, ".gserviceaccount.com", "")
  }

  runtime_project_roles = {
    app = [
      "roles/cloudsql.client",
      "roles/cloudsql.instanceUser",
      "roles/cloudtrace.agent",
      "roles/monitoring.metricWriter",
    ]
    worker = [
      "roles/cloudsql.client",
      "roles/cloudsql.instanceUser",
      "roles/cloudtrace.agent",
      "roles/monitoring.metricWriter",
    ]
    temporal = [
      "roles/cloudsql.client",
      "roles/cloudsql.instanceUser",
      "roles/monitoring.metricWriter",
    ]
  }

  runtime_project_role_bindings = merge([
    for service, roles in local.runtime_project_roles : {
      for role in roles : "${service}/${role}" => {
        service = service
        role    = role
      }
    }
  ]...)

  workload_identity_bindings = {
    app = {
      namespace       = var.workload_identity.app_namespace
      service_account = var.workload_identity.app_service_account
    }
    worker = {
      namespace       = var.workload_identity.worker_namespace
      service_account = var.workload_identity.worker_service_account
    }
    temporal = {
      namespace       = var.workload_identity.temporal_namespace
      service_account = var.workload_identity.temporal_service_account
    }
  }

  managed_secret_ids = var.secrets.create ? toset(var.secrets.secret_ids) : toset([])

  secret_access_by_service = var.secrets.create ? {
    for service, secret_ids in var.secrets.access :
    service => toset([
      for secret_id in secret_ids : secret_id
      if contains(tolist(local.managed_secret_ids), secret_id) && contains(keys(local.runtime_service_account_emails), service)
    ])
  } : {}

  runtime_secret_access_bindings = merge({}, [
    for service, secret_ids in local.secret_access_by_service : {
      for secret_id in secret_ids : "${service}/${secret_id}" => {
        service_account = local.runtime_service_account_emails[service]
        secret_id       = secret_id
      }
    }
  ]...)

  binary_authorization_attestor_name = coalesce(var.binary_authorization.attestor_name, "${local.resource_prefix}-build")
  binary_authorization_note_name     = coalesce(var.binary_authorization.note_name, "${local.resource_prefix}-attestor-note")
}
