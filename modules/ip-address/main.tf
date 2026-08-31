resource "google_compute_address" "regional" {
  count = var.type == "REGIONAL" ? 1 : 0

  project      = var.project_id
  name         = var.name
  region       = var.region
  address_type = "EXTERNAL"
  network_tier = var.network_tier
  ip_version   = var.ip_version
  description  = var.description
  labels       = var.labels

  lifecycle {
    precondition {
      condition     = var.region != null && trimspace(var.region) != ""
      error_message = "region is required when type is REGIONAL."
    }
  }
}

resource "google_compute_global_address" "global" {
  count = var.type == "GLOBAL" ? 1 : 0

  project      = var.project_id
  name         = var.name
  address_type = "EXTERNAL"
  ip_version   = var.ip_version
  description  = var.description
  labels       = var.labels
}
