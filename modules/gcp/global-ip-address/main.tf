resource "google_compute_global_address" "this" {
  project      = var.project_id
  name         = var.name
  address_type = "EXTERNAL"
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
