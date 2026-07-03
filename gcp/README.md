# CraftedSignal GCP Terraform Package

Production GCP Terraform package for CraftedSignal customer deployments.

This package is intentionally separate from the internal infrastructure repo. It contains the reusable customer-facing module, a production example, and operational documentation. It does not contain live Terraform state, internal account IDs, demo infrastructure, or customer-specific values.

## What It Creates

- Private GKE Autopilot cluster
- Private Cloud SQL PostgreSQL 18 instance
- Private service access and Cloud NAT
- KMS keys for GKE, Cloud SQL, Secret Manager, Artifact Registry, and Binary Authorization
- Binary Authorization policy and attestor
- Runtime service accounts with Workload Identity bindings
- Artifact Registry Docker repository with CMEK
- Secret Manager placeholders for runtime configuration
- Optional Cloud Armor policy and reCAPTCHA Enterprise key

## Usage

```hcl
module "craftedsignal" {
  source = "git::https://github.com/CraftedSignal/terraform.git//gcp/modules/platform?ref=gcp/v0.1.0"

  project_id = "customer-prod-project"
  region     = "europe-west1"
  app_domain = "craftedsignal.example.com"

  gke_rbac_security_group = "gke-security-groups@example.com"

  gke = {
    master_authorized_networks = [
      { cidr = "203.0.113.10/32", name = "operator-vpn" }
    ]
  }
}
```

See `examples/production` for a deployable root module.

## Package Contract

- Production only. No demo environment is packaged here.
- Module inputs and outputs are public API.
- Consumers must pin provider-scoped Git tags.
- Secret values should stay outside Terraform unless the customer explicitly accepts storing those values in Terraform state.
- Kubernetes deployment, DNS, and customer-specific runtime configuration stay in the consuming repo.

## Documentation

- `docs/prerequisites.md`
- `docs/architecture.md`
- `docs/deployment-integration.md`
- `docs/security.md`
- `docs/database-grants.sql.tpl`
- `docs/operations.md`
- `docs/upgrades.md`
- `docs/releases.md`
