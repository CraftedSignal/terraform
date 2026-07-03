# Production Example

This example deploys the production GCP substrate for CraftedSignal:

- Private GKE Autopilot cluster
- Private Cloud SQL PostgreSQL 18 instance
- KMS keys for GKE secrets, Cloud SQL, Secret Manager, Artifact Registry, and Binary Authorization
- Binary Authorization policy and attestor
- Workload Identity service accounts
- Artifact Registry Docker repository
- Cloud Armor policy for the application ingress
- Secret Manager placeholders for runtime configuration

Copy `terraform.tfvars.example` to `terraform.tfvars`, replace the project and network access values, then run:

```bash
terraform init
terraform plan
terraform apply
```

The example intentionally does not configure a Terraform backend. Production consumers should configure their own remote state backend in the root module.

Create the Google Groups for GKE security group in the customer Workspace or Cloud Identity domain before apply, then set `gke_rbac_security_group` to `gke-security-groups@<domain>`. Application database clients should use the Cloud SQL Auth Proxy or Cloud SQL connectors because the module enforces trusted-client-certificate SSL mode.
