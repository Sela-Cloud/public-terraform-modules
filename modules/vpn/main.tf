resource "google_compute_address" "this" {
  project = var.project_id
  name    = "${var.name}-ip"
  region  = var.region
}

resource "google_compute_vpn_gateway" "this" {
  project     = var.project_id
  name        = "${var.name}-gateway"
  region      = var.region
  network     = var.network
  description = var.description
}

resource "google_compute_forwarding_rule" "esp" {
  project     = var.project_id
  name        = "${var.name}-esp"
  region      = var.region
  ip_protocol = "ESP"
  ip_address  = google_compute_address.this.self_link
  target      = google_compute_vpn_gateway.this.self_link
}

resource "google_compute_forwarding_rule" "udp_500" {
  project     = var.project_id
  name        = "${var.name}-udp500"
  region      = var.region
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.this.self_link
  target      = google_compute_vpn_gateway.this.self_link
}

resource "google_compute_forwarding_rule" "udp_4500" {
  project     = var.project_id
  name        = "${var.name}-udp4500"
  region      = var.region
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.this.self_link
  target      = google_compute_vpn_gateway.this.self_link
}

resource "google_compute_vpn_tunnel" "this" {
  project                 = var.project_id
  name                    = var.name
  region                  = var.region
  description             = var.description
  peer_ip                 = var.peer_ip
  shared_secret           = var.shared_secret
  ike_version             = var.ike_version
  target_vpn_gateway      = google_compute_vpn_gateway.this.self_link
  local_traffic_selector  = var.local_traffic_selector
  remote_traffic_selector = var.remote_traffic_selector

  depends_on = [
    google_compute_forwarding_rule.esp,
    google_compute_forwarding_rule.udp_500,
    google_compute_forwarding_rule.udp_4500,
  ]
}
