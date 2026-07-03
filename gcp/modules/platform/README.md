# CraftedSignal GCP Platform Module

This module provisions the production GCP infrastructure substrate for CraftedSignal.

Use the package README and `gcp/docs` for architecture, security, and operations guidance.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 7.31 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 7.31 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.6 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_artifact_registry_repository.containers](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_artifact_registry_repository_iam_member.gke_reader](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_member) | resource |
| [google_artifact_registry_repository_iam_member.writers](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_member) | resource |
| [google_binary_authorization_attestor.build](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/binary_authorization_attestor) | resource |
| [google_binary_authorization_policy.policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/binary_authorization_policy) | resource |
| [google_compute_address.nat_egress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_firewall.deny_ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_global_address.private_services](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_network.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_router.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_security_policy.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_security_policy) | resource |
| [google_compute_subnetwork.gke](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_container_analysis_note.attestor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_analysis_note) | resource |
| [google_container_analysis_note_iam_member.attestation_writers](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_analysis_note_iam_member) | resource |
| [google_container_cluster.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |
| [google_dns_policy.logging](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_policy) | resource |
| [google_kms_crypto_key.artifact_registry](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key) | resource |
| [google_kms_crypto_key.attestor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key) | resource |
| [google_kms_crypto_key.cloudsql](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key) | resource |
| [google_kms_crypto_key.gke](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key) | resource |
| [google_kms_crypto_key.secrets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key) | resource |
| [google_kms_crypto_key_iam_member.artifact_registry_encrypt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_kms_crypto_key_iam_member.attestation_signers](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_kms_crypto_key_iam_member.cloudsql_encrypt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_kms_crypto_key_iam_member.gke_encrypt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_kms_crypto_key_iam_member.secretmanager_encrypt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_kms_crypto_key_version.attestor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_version) | resource |
| [google_kms_key_ring.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_key_ring) | resource |
| [google_project_iam_member.attestation_occurrence_writers](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.gke_node_roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.runtime_roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.required](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_recaptcha_enterprise_key.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/recaptcha_enterprise_key) | resource |
| [google_secret_manager_secret.db_passwords](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret.managed](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_iam_member.db_password_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_secret_manager_secret_iam_member.runtime_secret_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_secret_manager_secret_version.db_passwords](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_service_account.gke_nodes](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.runtime](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.workload_identity](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_service_networking_connection.private_vpc_connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |
| [google_sql_database.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) | resource |
| [google_sql_database.temporal](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) | resource |
| [google_sql_database.temporal_visibility](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) | resource |
| [google_sql_database_instance.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [google_sql_user.app_password](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |
| [google_sql_user.iam_service_accounts](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |
| [google_sql_user.temporal_password](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |
| [random_password.app_db](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.temporal_db](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [google_compute_network.existing](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |
| [google_compute_subnetwork.existing](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |
| [google_kms_crypto_key_version.attestor_public_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_crypto_key_version) | data source |
| [google_project.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_domain"></a> [app\_domain](#input\_app\_domain) | Public application domain, used for Cloud Armor/reCAPTCHA metadata and examples. Leave empty if DNS/LB is managed outside this module. | `string` | `""` | no |
| <a name="input_artifact_registry"></a> [artifact\_registry](#input\_artifact\_registry) | Artifact Registry Docker repository configuration. | <pre>object({<br/>    create        = optional(bool, true)<br/>    repository_id = optional(string, "craftedsignal")<br/>    description   = optional(string, "CraftedSignal production container images")<br/>  })</pre> | `{}` | no |
| <a name="input_artifact_registry_writer_members"></a> [artifact\_registry\_writer\_members](#input\_artifact\_registry\_writer\_members) | IAM members granted roles/artifactregistry.writer on the created repository, for example Workload Identity Federation deployers. | `list(string)` | `[]` | no |
| <a name="input_binary_authorization"></a> [binary\_authorization](#input\_binary\_authorization) | Binary Authorization policy, attestor, and attestation writer settings. | <pre>object({<br/>    create_resources           = optional(bool, true)<br/>    enforcement_mode           = optional(string, "DRYRUN_AUDIT_LOG_ONLY")<br/>    attestor_name              = optional(string)<br/>    note_name                  = optional(string)<br/>    attestation_writer_members = optional(list(string), [])<br/>    admission_whitelist_patterns = optional(list(string), [<br/>      "gke.gcr.io/*",<br/>      "gcr.io/gke-release/*",<br/>      "gcr.io/config-management-release/*",<br/>      "gcr.io/cloud-provider-vsphere/*",<br/>      "gcr.io/gkeconnect/*",<br/>      "gcr.io/gke-multi-cloud-release/*",<br/>      "gcr.io/kubebuilder/*",<br/>      "europe-west1-docker.pkg.dev/gke-release/*",<br/>      "europe-west4-docker.pkg.dev/gke-release/*",<br/>      "us-central1-docker.pkg.dev/gke-release/*",<br/>      "us-east1-docker.pkg.dev/gke-release/*",<br/>    ])<br/>  })</pre> | `{}` | no |
| <a name="input_cloud_armor"></a> [cloud\_armor](#input\_cloud\_armor) | Optional Cloud Armor policy for the GKE ingress BackendConfig. | <pre>object({<br/>    enabled                   = optional(bool, true)<br/>    policy_name               = optional(string)<br/>    recaptcha_enabled         = optional(bool, true)<br/>    recaptcha_enforcement     = optional(bool, false)<br/>    recaptcha_score_threshold = optional(number, 0.3)<br/>    waf_preview               = optional(bool, true)<br/>    login_rate_limit_count    = optional(number, 20)<br/>    login_rate_limit_window   = optional(number, 60)<br/>    signup_rate_limit_count   = optional(number, 5)<br/>    signup_rate_limit_window  = optional(number, 60)<br/>    reset_rate_limit_count    = optional(number, 5)<br/>    reset_rate_limit_window   = optional(number, 60)<br/>    global_rate_limit_count   = optional(number, 1000)<br/>    global_rate_limit_window  = optional(number, 60)<br/>  })</pre> | `{}` | no |
| <a name="input_cloudsql"></a> [cloudsql](#input\_cloudsql) | Cloud SQL PostgreSQL production settings. | <pre>object({<br/>    instance_name                     = optional(string)<br/>    database_version                  = optional(string, "POSTGRES_18")<br/>    ssl_mode                          = optional(string, "TRUSTED_CLIENT_CERTIFICATE_REQUIRED")<br/>    tier                              = optional(string, "db-custom-2-7680")<br/>    availability_type                 = optional(string, "REGIONAL")<br/>    disk_size                         = optional(number, 100)<br/>    disk_autoresize_limit             = optional(number, 1000)<br/>    deletion_protection               = optional(bool, true)<br/>    retained_backups                  = optional(number, 30)<br/>    backup_start_time                 = optional(string, "03:00")<br/>    maintenance_day                   = optional(number, 7)<br/>    maintenance_hour                  = optional(number, 3)<br/>    enable_iam_authentication         = optional(bool, true)<br/>    create_password_users             = optional(bool, false)<br/>    app_database_name                 = optional(string, "craftedsignal")<br/>    temporal_database_name            = optional(string, "temporal")<br/>    temporal_visibility_database_name = optional(string, "temporal_visibility")<br/>    app_password_user                 = optional(string, "craftedsignal")<br/>    temporal_password_user            = optional(string, "temporal")<br/>    database_flags                    = optional(map(string), {})<br/>  })</pre> | `{}` | no |
| <a name="input_enable_project_services"></a> [enable\_project\_services](#input\_enable\_project\_services) | Enable required GCP APIs in the target project. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment label. This module is intended for production deployments; default is prod. | `string` | `"prod"` | no |
| <a name="input_extra_project_services"></a> [extra\_project\_services](#input\_extra\_project\_services) | Additional GCP APIs to enable. | `list(string)` | `[]` | no |
| <a name="input_gke"></a> [gke](#input\_gke) | GKE Autopilot production cluster settings. | <pre>object({<br/>    cluster_name               = optional(string)<br/>    release_channel            = optional(string, "REGULAR")<br/>    deletion_protection        = optional(bool, true)<br/>    private_endpoint           = optional(bool, false)<br/>    binary_authorization       = optional(bool, true)<br/>    managed_prometheus         = optional(bool, true)<br/>    notification_topic_id      = optional(string, "")<br/>    configure_node_config      = optional(bool, true)<br/>    master_authorized_networks = optional(list(object({ cidr = string, name = string })), [])<br/>    maintenance_start_time     = optional(string, "2024-01-06T02:00:00Z")<br/>    maintenance_end_time       = optional(string, "2024-01-06T06:00:00Z")<br/>    maintenance_recurrence     = optional(string, "FREQ=WEEKLY;BYDAY=SA,SU")<br/>  })</pre> | `{}` | no |
| <a name="input_gke_rbac_security_group"></a> [gke\_rbac\_security\_group](#input\_gke\_rbac\_security\_group) | Google Groups for GKE security group used for Kubernetes RBAC user and group bindings. Must be named gke-security-groups@<domain>. | `string` | n/a | yes |
| <a name="input_kms"></a> [kms](#input\_kms) | KMS creation or adoption settings. Set create=false to use existing key IDs. | <pre>object({<br/>    create                   = optional(bool, true)<br/>    manage_iam               = optional(bool, true)<br/>    gke_key_id               = optional(string)<br/>    cloudsql_key_id          = optional(string)<br/>    secrets_key_id           = optional(string)<br/>    artifact_registry_key_id = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Additional labels applied to supported GCP resources. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Short deployment name used as a resource prefix. | `string` | `"craftedsignal"` | no |
| <a name="input_network"></a> [network](#input\_network) | Production VPC configuration. Set create=false to use an existing VPC and subnetwork by name. | <pre>object({<br/>    create                               = optional(bool, true)<br/>    network_name                         = optional(string)<br/>    network_id                           = optional(string)<br/>    subnetwork_name                      = optional(string)<br/>    subnetwork_id                        = optional(string)<br/>    subnet_cidr                          = optional(string, "10.10.0.0/20")<br/>    pods_cidr                            = optional(string, "10.20.0.0/14")<br/>    services_cidr                        = optional(string, "10.24.0.0/20")<br/>    pods_range_name                      = optional(string, "pods")<br/>    services_range_name                  = optional(string, "services")<br/>    master_cidr                          = optional(string, "172.16.0.0/28")<br/>    private_service_access_prefix_length = optional(number, 16)<br/>    create_private_service_access        = optional(bool, true)<br/>    enable_cloud_nat                     = optional(bool, true)<br/>    enable_dns_logging                   = optional(bool, true)<br/>    enable_flow_logs                     = optional(bool, true)<br/>    flow_logs_sampling                   = optional(number, 0.01)<br/>  })</pre> | `{}` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID that will host the CraftedSignal production infrastructure. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Primary GCP region for regional resources. | `string` | `"europe-west1"` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secret Manager placeholder secrets created for deployment-time configuration. Secret versions should be written outside Terraform unless intentionally managed as state. | <pre>object({<br/>    create     = optional(bool, true)<br/>    secret_ids = optional(list(string), ["craftedsignal-master-secret", "craftedsignal-license-key", "craftedsignal-config"])<br/>    access = optional(map(list(string)), {<br/>      app      = ["craftedsignal-master-secret", "craftedsignal-license-key", "craftedsignal-config"]<br/>      worker   = ["craftedsignal-master-secret", "craftedsignal-license-key", "craftedsignal-config"]<br/>      temporal = []<br/>    })<br/>  })</pre> | `{}` | no |
| <a name="input_service_account_ids"></a> [service\_account\_ids](#input\_service\_account\_ids) | GCP service account IDs. Keep each value within GCP's 30-character account\_id limit. | <pre>object({<br/>    gke_nodes = optional(string, "craftedsignal-prod-gke")<br/>    app       = optional(string, "craftedsignal-prod-app")<br/>    worker    = optional(string, "craftedsignal-prod-worker")<br/>    temporal  = optional(string, "craftedsignal-prod-temporal")<br/>  })</pre> | `{}` | no |
| <a name="input_service_accounts"></a> [service\_accounts](#input\_service\_accounts) | Service account creation or adoption settings. Set create=false to use existing service account emails. | <pre>object({<br/>    create          = optional(bool, true)<br/>    manage_iam      = optional(bool, true)<br/>    gke_nodes_email = optional(string)<br/>    app_email       = optional(string)<br/>    worker_email    = optional(string)<br/>    temporal_email  = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_workload_identity"></a> [workload\_identity](#input\_workload\_identity) | Kubernetes service accounts bound to GCP service accounts through GKE Workload Identity. | <pre>object({<br/>    enable_bindings          = optional(bool, true)<br/>    app_namespace            = optional(string, "craftedsignal")<br/>    app_service_account      = optional(string, "craftedsignal")<br/>    worker_namespace         = optional(string, "craftedsignal")<br/>    worker_service_account   = optional(string, "craftedsignal-worker")<br/>    temporal_namespace       = optional(string, "temporal-system")<br/>    temporal_service_account = optional(string, "temporal")<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_artifact_registry_repository"></a> [artifact\_registry\_repository](#output\_artifact\_registry\_repository) | Artifact Registry Docker repository metadata, if created. |
| <a name="output_binary_authorization_attestor_kms_key_version"></a> [binary\_authorization\_attestor\_kms\_key\_version](#output\_binary\_authorization\_attestor\_kms\_key\_version) | KMS key version used by the Binary Authorization attestor. |
| <a name="output_binary_authorization_attestor_name"></a> [binary\_authorization\_attestor\_name](#output\_binary\_authorization\_attestor\_name) | Binary Authorization attestor name, if Binary Authorization is enabled. |
| <a name="output_binary_authorization_attestor_note_id"></a> [binary\_authorization\_attestor\_note\_id](#output\_binary\_authorization\_attestor\_note\_id) | Container Analysis note ID used by the Binary Authorization attestor. |
| <a name="output_cloud_armor_security_policy_name"></a> [cloud\_armor\_security\_policy\_name](#output\_cloud\_armor\_security\_policy\_name) | Cloud Armor security policy name for GKE BackendConfig. |
| <a name="output_cloudsql_instance_connection_name"></a> [cloudsql\_instance\_connection\_name](#output\_cloudsql\_instance\_connection\_name) | Cloud SQL instance connection name for Cloud SQL connector or proxy. |
| <a name="output_cloudsql_instance_name"></a> [cloudsql\_instance\_name](#output\_cloudsql\_instance\_name) | Cloud SQL instance name. |
| <a name="output_cloudsql_private_ip_address"></a> [cloudsql\_private\_ip\_address](#output\_cloudsql\_private\_ip\_address) | Cloud SQL private IP address. |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | GKE cluster CA certificate. |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | GKE cluster endpoint. |
| <a name="output_cluster_location"></a> [cluster\_location](#output\_cluster\_location) | GKE cluster location. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | GKE Autopilot cluster name. |
| <a name="output_database_iam_users"></a> [database\_iam\_users](#output\_database\_iam\_users) | Cloud SQL IAM database usernames corresponding to runtime service accounts. |
| <a name="output_database_names"></a> [database\_names](#output\_database\_names) | Created PostgreSQL database names. |
| <a name="output_database_password_secret_ids"></a> [database\_password\_secret\_ids](#output\_database\_password\_secret\_ids) | Secret Manager IDs for generated database passwords when cloudsql.create\_password\_users is true. |
| <a name="output_kms_key_ids"></a> [kms\_key\_ids](#output\_kms\_key\_ids) | KMS key IDs. |
| <a name="output_nat_egress_ip"></a> [nat\_egress\_ip](#output\_nat\_egress\_ip) | Static Cloud NAT egress IP, if Cloud NAT is enabled. |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | VPC network ID. |
| <a name="output_network_name"></a> [network\_name](#output\_network\_name) | VPC network name. |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | GCP project ID. |
| <a name="output_recaptcha_site_key"></a> [recaptcha\_site\_key](#output\_recaptcha\_site\_key) | reCAPTCHA Enterprise site key name, if created. |
| <a name="output_region"></a> [region](#output\_region) | Primary GCP region. |
| <a name="output_secret_ids"></a> [secret\_ids](#output\_secret\_ids) | Secret Manager placeholder secret IDs created by the module. |
| <a name="output_service_account_emails"></a> [service\_account\_emails](#output\_service\_account\_emails) | Runtime and node service account emails. |
| <a name="output_subnetwork_id"></a> [subnetwork\_id](#output\_subnetwork\_id) | GKE subnetwork ID. |
| <a name="output_subnetwork_name"></a> [subnetwork\_name](#output\_subnetwork\_name) | GKE subnetwork name. |
| <a name="output_workload_identity_pool"></a> [workload\_identity\_pool](#output\_workload\_identity\_pool) | GKE Workload Identity pool. |
<!-- END_TF_DOCS -->

