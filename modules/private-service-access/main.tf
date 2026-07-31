data "google_compute_network" "this" {
  project = var.project_id
  name    = var.network
}

resource "google_compute_global_address" "this" {
  project       = var.project_id
  name          = var.name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  network       = data.google_compute_network.this.self_link
  prefix_length = var.prefix_length
  address       = var.address
}

resource "google_service_networking_connection" "this" {
  network                 = data.google_compute_network.this.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.this.name]
}
