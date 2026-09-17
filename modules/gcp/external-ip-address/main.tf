resource "google_compute_address" "this" {
  project      = var.project_id
  name         = var.name
  region       = var.region
  address_type = "EXTERNAL"
  network_tier = var.network_tier
  ip_version   = var.ip_version
  address      = var.assign_automatically ? null : var.address
  description  = var.description
  labels       = var.labels

  lifecycle {
    precondition {
      condition     = var.assign_automatically || (var.address != null && trimspace(var.address) != "")
      error_message = "address is required when assign_automatically is false."
    }
  }
}
