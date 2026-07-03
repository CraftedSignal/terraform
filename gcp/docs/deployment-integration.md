# Deployment Integration

Terraform provisions the production substrate. The consuming deployment repo remains responsible for Kubernetes releases, DNS, and runtime secret values.

## Application Runtime

Use the module outputs to configure the application:

```yaml
storage:
  driver: postgres
  properties:
    iam_auth: "true"
    instance_connection_name: "<cloudsql_instance_connection_name>"
    user: "<database_iam_users.app>"
    dbname: "craftedsignal"
```

The app and worker Kubernetes service accounts should be annotated with the GCP service accounts from `service_account_emails`.

## Temporal

The module creates the Temporal databases and a Temporal runtime service account. The deployment layer should run Temporal with either Cloud SQL Auth Proxy or the Cloud SQL connector and use the `temporal` IAM database user or the generated password secret if password users are explicitly enabled.

## Ingress

The module can create a Cloud Armor security policy. Attach `cloud_armor_security_policy_name` through the GKE BackendConfig or Gateway policy used by the deployment layer.

## Secrets

The module creates Secret Manager secret containers only. Write secret values from the customer secret-management workflow, not from this module, unless the customer accepts Terraform state containing values.

