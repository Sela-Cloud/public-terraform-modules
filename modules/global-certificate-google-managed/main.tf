resource "google_certificate_manager_certificate" "this" {
  project     = var.project_id
  name        = var.name
  description = var.description
  location    = "global"
  scope       = "DEFAULT"

  managed {
    domains = var.domain_names
    dns_authorizations = var.authorization_type == "dns_authorization" ? [
      for auth_name in var.dns_authorization_names :
      "projects/${var.project_id}/locations/global/dnsAuthorizations/${auth_name}"
    ] : null
  }

  lifecycle {
    precondition {
      condition     = var.authorization_type != "dns_authorization" || length(var.dns_authorization_names) > 0
      error_message = "At least one DNS authorization is required when authorization_type is 'dns_authorization'."
    }
  }
}
