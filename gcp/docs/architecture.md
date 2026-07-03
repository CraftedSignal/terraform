# Architecture

This module provisions the GCP infrastructure layer for a production CraftedSignal deployment.

## Included

- VPC-native private GKE Autopilot cluster with Workload Identity.
- Private Cloud SQL PostgreSQL with private service access, backups, point-in-time recovery, audit-oriented flags, Query Insights, and CMEK.
- Runtime service accounts for the app, worker, and Temporal workloads.
- Cloud SQL IAM database users for passwordless application authentication.
- Artifact Registry Docker repository for production images.
- KMS keys for GKE, Cloud SQL, and Secret Manager.
- Secret Manager placeholders for deployment-time configuration.
- Optional Cloud Armor policy and reCAPTCHA Enterprise site key.

## Not Included

- Terraform backend or state storage.
- Customer-specific DNS records.
- Kubernetes Helm releases.
- Secret values such as license keys, SMTP credentials, or AI provider tokens.
- PostgreSQL schema grants. See `gcp/docs/database-grants.sql.tpl`.

## Runtime Integration

The application can use Cloud SQL IAM authentication with module outputs:

```yaml
storage:
  driver: postgres
  properties:
    iam_auth: "true"
    instance_connection_name: "PROJECT:REGION:INSTANCE"
    user: "craftedsignal-prod-app@PROJECT.iam"
    dbname: "craftedsignal"
```

For GKE, bind Kubernetes service accounts to the output GCP service accounts through the Workload Identity annotations used by the deployment chart.

