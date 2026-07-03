resource "google_container_analysis_note" "attestor" {
  count = 1

  name    = local.binary_authorization_note_name
  project = var.project_id

  attestation_authority {
    hint {
      human_readable_name = "CraftedSignal ${var.environment} build attestor"
    }
  }

  depends_on = [google_project_service.required]
}

resource "google_binary_authorization_attestor" "build" {
  count = 1

  name    = local.binary_authorization_attestor_name
  project = var.project_id

  attestation_authority_note {
    note_reference = google_container_analysis_note.attestor[0].name

    public_keys {
      id = google_kms_crypto_key_version.attestor[0].id

      pkix_public_key {
        public_key_pem      = data.google_kms_crypto_key_version.attestor_public_key[0].public_key[0].pem
        signature_algorithm = data.google_kms_crypto_key_version.attestor_public_key[0].public_key[0].algorithm
      }
    }
  }

  depends_on = [google_project_service.required]
}

resource "google_binary_authorization_policy" "policy" {
  count = 1

  project = var.project_id

  default_admission_rule {
    evaluation_mode         = "REQUIRE_ATTESTATION"
    enforcement_mode        = var.binary_authorization.enforcement_mode
    require_attestations_by = [google_binary_authorization_attestor.build[0].name]
  }

  dynamic "admission_whitelist_patterns" {
    for_each = toset(var.binary_authorization.admission_whitelist_patterns)
    content {
      name_pattern = admission_whitelist_patterns.value
    }
  }

  depends_on = [google_project_service.required]
}

resource "google_kms_crypto_key_iam_member" "attestation_signers" {
  for_each = toset(var.binary_authorization.attestation_writer_members)

  crypto_key_id = google_kms_crypto_key.attestor[0].id
  role          = "roles/cloudkms.signerVerifier"
  member        = each.key
}

resource "google_container_analysis_note_iam_member" "attestation_writers" {
  for_each = toset(var.binary_authorization.attestation_writer_members)

  note    = google_container_analysis_note.attestor[0].name
  project = var.project_id
  role    = "roles/containeranalysis.notes.attacher"
  member  = each.key
}

resource "google_project_iam_member" "attestation_occurrence_writers" {
  for_each = toset(var.binary_authorization.attestation_writer_members)

  project = var.project_id
  role    = "roles/containeranalysis.occurrences.editor"
  member  = each.key
}
