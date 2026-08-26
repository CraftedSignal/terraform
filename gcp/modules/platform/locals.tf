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
    "confidentialcomputing.googleapis.com",
    "container.googleapis.com",
    "containeranalysis.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "sts.googleapis.com",
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

  existing_network_id          = try(coalesce(var.network.network_id, try(data.google_compute_network.existing[0].id, null)), null)
  existing_network_name        = try(data.google_compute_network.existing[0].name, null)
  existing_subnetwork_id       = try(coalesce(var.network.subnetwork_id, try(data.google_compute_subnetwork.existing[0].id, null)), null)
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

  create_service_accounts = var.service_accounts.create
  manage_service_account_iam = (
    var.service_accounts.create || var.service_accounts.manage_iam
  )

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

  gke_node_service_account_email = local.create_service_accounts ? google_service_account.gke_nodes[0].email : var.service_accounts.gke_nodes_email

  runtime_service_account_emails = local.create_service_accounts ? {
    for name, account in google_service_account.runtime :
    name => account.email
    } : {
    app      = var.service_accounts.app_email
    worker   = var.service_accounts.worker_email
    temporal = var.service_accounts.temporal_email
  }

  runtime_service_account_names = local.create_service_accounts ? {
    for name, account in google_service_account.runtime :
    name => account.name
    } : {
    app      = "projects/${var.project_id}/serviceAccounts/${var.service_accounts.app_email}"
    worker   = "projects/${var.project_id}/serviceAccounts/${var.service_accounts.worker_email}"
    temporal = "projects/${var.project_id}/serviceAccounts/${var.service_accounts.temporal_email}"
  }

  create_kms_keys                       = var.kms.create
  gke_kms_key_id                        = local.create_kms_keys ? google_kms_crypto_key.gke[0].id : var.kms.gke_key_id
  cloudsql_kms_key_id                   = local.create_kms_keys ? google_kms_crypto_key.cloudsql[0].id : var.kms.cloudsql_key_id
  secrets_kms_key_id                    = local.create_kms_keys ? google_kms_crypto_key.secrets[0].id : var.kms.secrets_key_id
  artifact_registry_kms_key_id          = local.create_kms_keys ? google_kms_crypto_key.artifact_registry[0].id : var.kms.artifact_registry_key_id
  platform_kek_kms_key_id               = local.create_kms_keys ? google_kms_crypto_key.platform_kek[0].id : var.kms.platform_kek_key_id
  create_binary_authorization_resources = var.binary_authorization.create_resources
  binary_authorization_attestor_kms_key_id = local.create_binary_authorization_resources ? (
    local.create_kms_keys ? google_kms_crypto_key.attestor[0].id : var.kms.attestor_key_id
  ) : null

  create_key_broker_service_account = var.application_encryption.create_key_broker_service_account
  key_broker_service_account_email  = local.create_key_broker_service_account ? google_service_account.key_broker[0].email : var.application_encryption.key_broker_service_account_email
  key_broker_service_account_name   = local.create_key_broker_service_account ? google_service_account.key_broker[0].name : "projects/${var.project_id}/serviceAccounts/${var.application_encryption.key_broker_service_account_email}"
  application_encryption_runtime_services = var.application_encryption.grant_runtime_service_accounts ? toset([
    for service in var.application_encryption.runtime_services : service
    if contains(keys(local.runtime_service_account_emails), service)
  ]) : toset([])

  confidential_space_attestation                   = var.application_encryption.confidential_space_attestation
  confidential_space_attestation_enabled           = local.confidential_space_attestation.enabled
  confidential_space_workload_identity_pool_id     = coalesce(local.confidential_space_attestation.pool_id, "${var.name}-${var.environment}-attest")
  confidential_space_workload_identity_provider_id = local.confidential_space_attestation.provider_id
  confidential_space_signature_assertions          = [for fingerprint in local.confidential_space_attestation.signing_key_fingerprints : "ECDSA_P256_SHA256:${fingerprint}"]
  confidential_space_allowed_service_account_emails = (
    length(local.confidential_space_attestation.allowed_service_accounts) > 0 ?
    local.confidential_space_attestation.allowed_service_accounts :
    [local.key_broker_service_account_email]
  )
  confidential_space_workload_identity_conditions = concat(
    length(local.confidential_space_attestation.allowed_image_digests) > 0 ? [
      "assertion.submods.container.image_digest in ${jsonencode(local.confidential_space_attestation.allowed_image_digests)}",
    ] : [],
    length(local.confidential_space_signature_assertions) > 0 ? [
      "${jsonencode(local.confidential_space_signature_assertions)}.exists(fingerprint, fingerprint in assertion.submods.container.image_signatures.map(sig, sig.signature_algorithm + ':' + sig.key_id))",
    ] : []
  )
  confidential_space_attestation_conditions = concat(
    [
      "assertion.swname == 'CONFIDENTIAL_SPACE'",
      "'STABLE' in assertion.submods.confidential_space.support_attributes",
      "assertion.submods.gce.project_number == '${data.google_project.current.number}'",
    ],
    length(local.confidential_space_workload_identity_conditions) > 0 ? [
      "(${join(" || ", local.confidential_space_workload_identity_conditions)})",
    ] : [],
    length(local.confidential_space_allowed_service_account_emails) > 0 ? [
      "assertion.google_service_accounts.exists(sa, sa in ${jsonencode(local.confidential_space_allowed_service_account_emails)})",
    ] : []
  )
  confidential_space_attestation_condition = join(" && ", local.confidential_space_attestation_conditions)

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
