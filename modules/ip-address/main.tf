resource "google_compute_address" "regional" {
  count = var.type == "REGIONAL" ? 1 : 0

  project      = var.project_id
  name         = var.name
  region       = var.region
  address_type = var.address_type
  network_tier = var.address_type == "EXTERNAL" ? var.network_tier : null
  network      = var.address_type == "INTERNAL" ? var.network : null
  subnetwork   = var.address_type == "INTERNAL" ? var.subnetwork : null
  purpose      = var.address_type == "INTERNAL" ? var.purpose : null
  ip_version   = var.address_type == "INTERNAL" ? "IPV4" : var.ip_version
  address      = var.assign_automatically ? null : var.address
  description  = var.description
  labels       = var.labels

  lifecycle {
    precondition {
      condition     = var.region != null && trimspace(var.region) != ""
      error_message = "region is required when type is REGIONAL."
    }
    precondition {
      condition     = var.address_type != "INTERNAL" || (var.network != null && trimspace(var.network) != "")
      error_message = "network is required when address_type is INTERNAL."
    }
    precondition {
      condition     = var.address_type != "INTERNAL" || (var.subnetwork != null && trimspace(var.subnetwork) != "")
      error_message = "subnetwork is required when address_type is INTERNAL."
    }
    precondition {
      condition     = var.assign_automatically || (var.address != null && trimspace(var.address) != "")
      error_message = "address is required when assign_automatically is false."
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
