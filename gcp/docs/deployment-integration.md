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

Database clients should connect through the Cloud SQL Auth Proxy or Cloud SQL language connectors. The module enforces trusted-client-certificate SSL mode on the instance; direct private-IP clients must provide trusted client certificates.

## Temporal

The module creates the Temporal databases and a Temporal runtime service account. The deployment layer should run Temporal with either Cloud SQL Auth Proxy or the Cloud SQL connector and use the `temporal` IAM database user or the generated password secret if password users are explicitly enabled.

## Ingress

The module can create a Cloud Armor security policy. Attach `cloud_armor_security_policy_name` through the GKE BackendConfig or Gateway policy used by the deployment layer.

## Binary Authorization

The module can enforce Binary Authorization by default. Any deployment workflow that targets a cluster using `PROJECT_SINGLETON_POLICY_ENFORCE` must create an attestation for the exact image digest before Helm or `kubectl apply` rolls out the workload.

For manual GitHub Actions deployments, grant the workflow identity through `binary_authorization.attestation_writer_members`, then add a step like this after the image digest is resolved and before the Kubernetes deployment step:

```bash
gcloud beta container binauthz attestations sign-and-create \
  --project "$PROJECT_ID" \
  --artifact-url "$IMAGE_DIGEST_URL" \
  --note "$(terraform output -raw binary_authorization_attestor_note_id)" \
  --keyversion "$(terraform output -raw binary_authorization_attestor_kms_key_version)"
```

`IMAGE_DIGEST_URL` must be a digest reference such as `REGION-docker.pkg.dev/PROJECT/REPOSITORY/IMAGE@sha256:...`, not a mutable tag. Use `binary_authorization.enforcement_mode = "DRYRUN_AUDIT_LOG_ONLY"` until every image that the workflow deploys is attested.

## Secrets

The module creates Secret Manager secret containers only. Write secret values from the customer secret-management workflow, not from this module, unless the customer accepts Terraform state containing values.
