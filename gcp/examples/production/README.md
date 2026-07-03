# Production Example

This example deploys the production GCP substrate for CraftedSignal:

- Private GKE Autopilot cluster
- Private Cloud SQL PostgreSQL instance
- KMS keys for GKE secrets, Cloud SQL, and Secret Manager
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

