data "google_compute_address" "existing" {
  count   = var.existing_static_ip_name == null ? 0 : 1
  project = var.project_id
  region  = var.region
  name    = var.existing_static_ip_name
}

resource "google_compute_address" "this" {
  count        = var.existing_static_ip_name == null ? 1 : 0
  project      = var.project_id
  name         = "${var.name}-ip"
  region       = var.region
  address_type = "EXTERNAL"
}

locals {
  gateway_ip_self_link = var.existing_static_ip_name == null ? google_compute_address.this[0].self_link : data.google_compute_address.existing[0].self_link
  gateway_ip_address   = var.existing_static_ip_name == null ? google_compute_address.this[0].address : data.google_compute_address.existing[0].address
}

resource "google_compute_vpn_gateway" "this" {
  project     = var.project_id
  name        = var.name
  region      = var.region
  network     = var.network
  description = var.description
}

resource "google_compute_forwarding_rule" "esp" {
  project     = var.project_id
  name        = "${var.name}-esp"
  region      = var.region
  ip_protocol = "ESP"
  ip_address  = local.gateway_ip_self_link
  target      = google_compute_vpn_gateway.this.self_link
}

resource "google_compute_forwarding_rule" "udp_500" {
  project     = var.project_id
  name        = "${var.name}-udp500"
  region      = var.region
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = local.gateway_ip_self_link
  target      = google_compute_vpn_gateway.this.self_link
}

resource "google_compute_forwarding_rule" "udp_4500" {
  project     = var.project_id
  name        = "${var.name}-udp4500"
  region      = var.region
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = local.gateway_ip_self_link
  target      = google_compute_vpn_gateway.this.self_link
}
