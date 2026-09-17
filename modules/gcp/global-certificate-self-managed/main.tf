resource "google_certificate_manager_certificate" "this" {
  project     = var.project_id
  name        = var.name
  description = var.description
  location    = "global"
  scope       = "DEFAULT"

  self_managed {
    pem_certificate = var.pem_certificate
    pem_private_key = var.pem_private_key
  }
}
