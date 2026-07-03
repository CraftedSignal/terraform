data "google_compute_network" "existing" {
  count = var.network.create ? 0 : 1

  name    = var.network.network_name
  project = var.project_id
}

data "google_compute_subnetwork" "existing" {
  count = var.network.create ? 0 : 1

  name    = var.network.subnetwork_name
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "main" {
  count = var.network.create ? 1 : 0

  name                    = local.network_name
  auto_create_subnetworks = false
  project                 = var.project_id

  depends_on = [google_project_service.required]
}

resource "google_compute_subnetwork" "gke" {
  count = var.network.create ? 1 : 0

  name          = local.subnetwork_name
  ip_cidr_range = var.network.subnet_cidr
  region        = var.region
  network       = google_compute_network.main[0].id
  project       = var.project_id

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = var.network.pods_range_name
    ip_cidr_range = var.network.pods_cidr
  }

  secondary_ip_range {
    range_name    = var.network.services_range_name
    ip_cidr_range = var.network.services_cidr
  }

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = var.network.flow_logs_sampling
    metadata             = "EXCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "deny_ingress" {
  count = var.network.create ? 1 : 0

  name      = "${local.resource_prefix}-deny-ingress"
  network   = google_compute_network.main[0].name
  project   = var.project_id
  direction = "INGRESS"
  priority  = 65534

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_global_address" "private_services" {
  count = var.network.create_private_service_access ? 1 : 0

  name          = "${local.resource_prefix}-psa"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.network.private_service_access_prefix_length
  network       = local.network_id

  depends_on = [google_project_service.required]
}

resource "google_service_networking_connection" "private_vpc_connection" {
  count = var.network.create_private_service_access ? 1 : 0

  network                 = local.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_services[0].name]

  depends_on = [google_project_service.required]
}

resource "google_compute_address" "nat_egress" {
  count = var.network.enable_cloud_nat ? 1 : 0

  name         = "${local.resource_prefix}-nat-egress"
  region       = var.region
  project      = var.project_id
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  depends_on = [google_project_service.required]
}

resource "google_compute_router" "main" {
  count = var.network.enable_cloud_nat ? 1 : 0

  name    = "${local.resource_prefix}-router"
  region  = var.region
  network = local.network_id
  project = var.project_id
}

resource "google_compute_router_nat" "main" {
  count = var.network.enable_cloud_nat ? 1 : 0

  name                               = "${local.resource_prefix}-nat"
  router                             = google_compute_router.main[0].name
  region                             = var.region
  project                            = var.project_id
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat_egress[0].self_link]
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = local.subnetwork_id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

resource "google_dns_policy" "logging" {
  count = var.network.enable_dns_logging ? 1 : 0

  name                      = "${local.resource_prefix}-dns-logging"
  project                   = var.project_id
  enable_inbound_forwarding = false
  enable_logging            = true

  networks {
    network_url = local.network_id
  }

  depends_on = [google_project_service.required]
}
