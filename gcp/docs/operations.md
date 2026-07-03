# Operations

## Connect to GKE

```bash
gcloud container clusters get-credentials "$(terraform output -raw cluster_name)" \
  --region "$(terraform output -raw region)" \
  --project "$(terraform output -raw project_id)"
```

## Push Images

Use the `artifact_registry_repository.url` output as the image repository prefix. Deploy images by digest in production.

## Cloud SQL

The app should prefer Cloud SQL IAM authentication:

```yaml
storage:
  driver: postgres
  properties:
    iam_auth: "true"
    instance_connection_name: "<terraform output cloudsql_instance_connection_name>"
    user: "<terraform output database_iam_users.app>"
    dbname: "craftedsignal"
```

Run the database grants in `gcp/docs/database-grants.sql.tpl` after Terraform creates the IAM database users.

Use the Cloud SQL Auth Proxy or Cloud SQL language connectors for application and operator access. The instance enforces trusted-client-certificate SSL mode; direct private-IP clients need trusted client certificates.
