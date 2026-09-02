resource "google_certificate_manager_dns_authorization" "this" {
  project     = var.project_id
  name        = var.name
  location    = "global"
  type        = var.type
  domain      = var.domain
  description = var.description
}
