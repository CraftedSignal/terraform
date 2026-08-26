# Air-Gap and Private Deployment

CraftedSignal supports several deployment boundaries. The Terraform package covers a private GCP production substrate; the application can also run on customer-operated infrastructure or in a fully air-gapped environment.

## Operating Models

| Model | Infrastructure owner | Network model | Key model | Typical use |
| --- | --- | --- | --- | --- |
| Secured SaaS | CraftedSignal | Private GCP runtime with controlled public ingress | CraftedSignal-managed KMS/CMEK and application KEK | Teams that want managed operations without moving logs into CraftedSignal |
| Sovereign SaaS | CraftedSignal plus customer key project | Private GCP runtime with customer-governed key release | Customer KMS grant to attested Confidential Space identity | Teams that allow SaaS operations but require customer-controlled root keys |
| Private cloud | Customer | Customer VPC/VNet and internal ingress policy | Customer KMS/HSM or module-created CMEK | Regulated teams that operate the infrastructure boundary |
| Fully air-gapped | Customer | No public outbound access; internal IPs only | Local master secret or customer secret-management process | Isolated environments where internet access is prohibited |

CraftedSignal remains a detection-governance control plane in every model. Customer logs and telemetry stay in the SIEM.

## What This Terraform Package Covers

The GCP package provisions:

- Private GKE Autopilot nodes.
- Private Cloud SQL with no public IPv4 address.
- Private service access and controlled egress through Cloud NAT.
- CMEK for Cloud SQL, GKE secrets, Secret Manager, Artifact Registry, and application-level tenant DEK wrapping.
- Binary Authorization resources for digest-attested image deployment.
- Optional Confidential GKE Nodes for encrypted memory in supported GKE runtimes.
- Optional Confidential Space Workload Identity Federation for attested key access.

This is a private-cloud or sovereign-cloud substrate. It is not a disconnected GCP environment: managed GKE, Cloud SQL, KMS, Artifact Registry, IAM, and Binary Authorization still depend on Google Cloud control-plane APIs.

## Hardening for Private GCP Deployments

For stricter private deployments:

1. Keep `network.enable_flow_logs = true` and export logs to the customer's logging project or SIEM.
2. Keep Cloud SQL on private IP and use IAM database authentication or trusted client certificates.
3. Use `kms.create = false` when the customer owns pre-created KMS keys, and provide all key IDs explicitly.
4. Enable `gke.confidential_nodes = true` only for new clusters or planned cutovers.
5. Enable `application_encryption.confidential_space_attestation` when a customer-owned KEK should release only to attested workloads.
6. Keep `binary_authorization.enforcement_mode = "ENFORCED_BLOCK_AND_AUDIT_LOG"` only after every manual deployment workflow signs the exact image digest it deploys.
7. Keep runtime secrets out of Terraform state unless the customer has explicitly accepted that state exposure.

## Fully Air-Gapped Deployments

A fully air-gapped deployment should not depend on GCP managed services or GitHub Actions at runtime. Use the application binary or a customer-managed Kubernetes deployment inside the isolated network.

Required design points:

- Start the application with air-gapped mode enabled so public outbound dials and DNS lookups are blocked by the application network layer.
- Address SIEMs, OIDC, local AI, SMTP, and feed mirrors by private IP or by infrastructure DNS that never resolves through public DNS.
- Use a local PostgreSQL or SQLite database.
- Provide `security.master_secret` from the customer's secret-management process. If the customer uses an HSM or vault, inject the runtime secret from that system instead of committing it to config files.
- Run AI through a local OpenAI-compatible endpoint such as Ollama, or disable AI entirely.
- Import threat-feed and rule bundles through an internal mirror or manual upload.
- Use OS firewalls, network namespaces, Kubernetes NetworkPolicy, or egress gateways to enforce deny-by-default networking below the application.

The application-level key hierarchy still applies in air-gapped mode: per-company tenant keys protect tenant credentials and sensitive settings; those keys are wrapped by the deployment's master key material. In a customer-operated environment, the customer's backup and break-glass procedure must protect the master secret with the same rigor as a root key.

## Deployment Without GitHub Actions

The packaged Terraform docs assume manual GitHub Actions for connected GCP deployments. In an air-gapped environment, replace that with internal CI:

- Mirror release artifacts into an internal registry.
- Verify checksums, signatures, and SBOMs before promotion.
- Pin deployments by immutable digest.
- Record human approval and deployment evidence in the customer's change system.
- Keep rollback artifacts available in the same internal registry.

For connected private GCP deployments that still use GitHub Actions, the manual workflow must create the Binary Authorization attestation after resolving the Artifact Registry digest and before Helm or `kubectl apply` rolls out the workload.

## Evidence to Preserve

Collect these records for audit and sovereignty evidence:

- Terraform plan and apply logs.
- KMS key inventory, IAM bindings, rotation history, and access logs.
- Confidential Space provider conditions and workload attestation policy.
- Binary Authorization attestations and admission decisions.
- GKE and Cloud SQL configuration evidence showing private networking and CMEK.
- Independent penetration test and major-change security review findings, remediation status, and closure evidence.
- CraftedSignal application audit logs for approvals, deploys, AI actions, settings changes, and user administration.
