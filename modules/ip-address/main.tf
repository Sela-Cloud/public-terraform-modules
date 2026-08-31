resource "google_compute_address" "this" {
  project      = var.project_id
  name         = var.name
  region       = var.region
  address_type = "EXTERNAL"
  network_tier = var.network_tier
  description  = var.description
  labels       = var.labels
}
