resource "google_dns_record_set" "this" {
  project      = var.project_id
  managed_zone = var.managed_zone
  name         = var.name
  type         = var.type
  ttl          = var.ttl
  rrdatas      = var.rrdatas
}
