# Production Example

This example deploys the production GCP substrate for CraftedSignal:

- Private GKE Autopilot cluster
- Private Cloud SQL PostgreSQL 18 instance
- KMS keys for GKE secrets, Cloud SQL, Secret Manager, Artifact Registry, Binary Authorization, and application-level tenant DEK wrapping
- Binary Authorization policy and attestor
- Workload Identity service accounts
- Application encryption key-broker service account with platform KEK access; direct runtime KEK access is opt-in
- Optional Confidential GKE Nodes and Confidential Space attestation
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

`enable_confidential_gke_nodes` is a cluster creation-time setting. Turn it on for new clusters, or plan a cluster cutover before enabling it on an existing deployment.

When `enable_confidential_space_attestation` is true, populate either `confidential_space_allowed_image_digests` or `confidential_space_signing_key_fingerprints` before granting a customer-owned KMS key to the returned attested identity.

If Binary Authorization enforcement is left at the module default, your deployment workflow must create an attestation for each image digest before applying Helm charts or Kubernetes manifests. See `gcp/docs/deployment-integration.md` for the manual GitHub Actions pattern.
