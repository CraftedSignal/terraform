resource "google_recaptcha_enterprise_key" "app" {
  count = local.recaptcha_enabled ? 1 : 0

  project      = var.project_id
  display_name = local.resource_prefix

  web_settings {
    integration_type  = "SCORE"
    allow_all_domains = false
    allowed_domains   = [var.app_domain]
  }

  depends_on = [google_project_service.required]
}

resource "google_compute_security_policy" "app" {
  count = var.cloud_armor.enabled ? 1 : 0

  project     = var.project_id
  name        = local.cloud_armor_name
  description = "Cloud Armor policy for CraftedSignal ${var.environment}"
  type        = "CLOUD_ARMOR"

  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable = true
    }
  }

  advanced_options_config {
    json_parsing                 = "STANDARD"
    log_level                    = "VERBOSE"
    request_body_inspection_size = "64KB"
  }

  dynamic "recaptcha_options_config" {
    for_each = local.recaptcha_enabled ? [1] : []
    content {
      redirect_site_key = google_recaptcha_enterprise_key.app[0].name
    }
  }

  rule {
    action      = "allow"
    priority    = 900
    description = "Allow health check endpoints"

    match {
      expr {
        expression = "request.path.matches('/health/.*')"
      }
    }
  }

  dynamic "rule" {
    for_each = local.recaptcha_enabled && var.cloud_armor.recaptcha_enforcement ? [1] : []
    content {
      action      = "deny(403)"
      priority    = 1000
      description = "Block low-score reCAPTCHA requests"

      match {
        expr {
          expression = "token.recaptcha_action.score < ${var.cloud_armor.recaptcha_score_threshold}"
        }
      }
    }
  }

  rule {
    action      = "throttle"
    priority    = 2000
    description = "Rate limit login attempts"

    match {
      expr {
        expression = "request.path.matches('/login') && request.method == 'POST'"
      }
    }

    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"
      enforce_on_key = "IP"

      rate_limit_threshold {
        count        = var.cloud_armor.login_rate_limit_count
        interval_sec = var.cloud_armor.login_rate_limit_window
      }
    }
  }

  rule {
    action      = "throttle"
    priority    = 2100
    description = "Rate limit password reset attempts"

    match {
      expr {
        expression = "request.path.matches('/forgot-password') && request.method == 'POST'"
      }
    }

    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"
      enforce_on_key = "IP"

      rate_limit_threshold {
        count        = 5
        interval_sec = 60
      }
    }
  }

  rule {
    action      = "allow"
    priority    = 2500
    description = "Allow rule and hunt editor endpoints; detection content can trigger generic OWASP signatures"

    match {
      expr {
        expression = "request.path.matches('^/(?:rules|hunts)(?:/.*)?$')"
      }
    }
  }

  rule {
    action      = "deny(403)"
    priority    = 3000
    preview     = var.cloud_armor.waf_preview
    description = "OWASP SQL injection"

    match {
      expr {
        expression = "evaluatePreconfiguredWaf('sqli-v33-stable', {'sensitivity': 1})"
      }
    }
  }

  rule {
    action      = "deny(403)"
    priority    = 3100
    preview     = var.cloud_armor.waf_preview
    description = "OWASP cross-site scripting"

    match {
      expr {
        expression = "evaluatePreconfiguredWaf('xss-v33-stable', {'sensitivity': 1})"
      }
    }
  }

  rule {
    action      = "deny(403)"
    priority    = 3200
    preview     = var.cloud_armor.waf_preview
    description = "OWASP local file inclusion"

    match {
      expr {
        expression = "evaluatePreconfiguredWaf('lfi-v33-stable', {'sensitivity': 1})"
      }
    }
  }

  rule {
    action      = "deny(403)"
    priority    = 3300
    preview     = var.cloud_armor.waf_preview
    description = "OWASP remote file inclusion"

    match {
      expr {
        expression = "evaluatePreconfiguredWaf('rfi-v33-stable', {'sensitivity': 1})"
      }
    }
  }

  rule {
    action      = "deny(403)"
    priority    = 3400
    preview     = var.cloud_armor.waf_preview
    description = "OWASP remote code execution"

    match {
      expr {
        expression = "evaluatePreconfiguredWaf('rce-v33-stable', {'sensitivity': 1})"
      }
    }
  }

  rule {
    action      = "deny(403)"
    priority    = 3500
    preview     = var.cloud_armor.waf_preview
    description = "OWASP protocol attack"

    match {
      expr {
        expression = "evaluatePreconfiguredWaf('protocolattack-v33-stable', {'sensitivity': 1})"
      }
    }
  }

  rule {
    action      = "deny(403)"
    priority    = 3600
    preview     = var.cloud_armor.waf_preview
    description = "Apache Log4j CVE canary"

    match {
      expr {
        expression = "evaluatePreconfiguredExpr('cve-canary')"
      }
    }
  }

  rule {
    action      = "allow"
    priority    = 2147483647
    description = "Default allow"

    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }

  depends_on = [google_project_service.required]
}
