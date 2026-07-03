# Prerequisites

## Required Tools

| Tool | Minimum | Notes |
| --- | --- | --- |
| Terraform | `>= 1.7.0` | CI currently validates with Terraform `1.15.7`. |
| gcloud CLI | Current stable | Used for authentication, API enablement checks, and GKE credentials. |
| kubectl | Current stable | Needed after Terraform for Kubernetes deployment. |
| Helm | `>= 3.14` | Needed if deploying CraftedSignal through the Helm chart. |

## GCP Project

Use a dedicated production project. The module can enable the required APIs, but the caller must have permission to create:

- Compute networks, subnets, routers, NAT, and private service access.
- GKE Autopilot clusters.
- Cloud SQL PostgreSQL instances.
- Cloud KMS keys and IAM bindings.
- Secret Manager secrets.
- Artifact Registry repositories.
- Cloud Armor policies and reCAPTCHA Enterprise keys when enabled.
- Binary Authorization policy, attestor, and Container Analysis note.

## Identity Prerequisites

Create the Google Groups for GKE security group before applying the module. GKE requires the group name format `gke-security-groups@<workspace-or-cloud-identity-domain>`, and the module exposes this as the required `gke_rbac_security_group` input.

## Terraform State

The package does not create or configure its own Terraform backend. Use a remote backend controlled by the customer, such as a versioned GCS bucket with restricted IAM.

## DNS

The module does not manage public DNS records. Point DNS at the ingress or load-balancer address created by the deployment layer.
