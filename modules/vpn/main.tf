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
  local_traffic_selector  = var.routing_mode == "ROUTE_BASED" ? ["0.0.0.0/0"] : var.local_traffic_selector
  remote_traffic_selector = var.routing_mode == "ROUTE_BASED" ? ["0.0.0.0/0"] : var.remote_traffic_selector

  depends_on = [
    google_compute_forwarding_rule.esp,
    google_compute_forwarding_rule.udp_500,
    google_compute_forwarding_rule.udp_4500,
  ]

  lifecycle {
    precondition {
      condition     = var.routing_mode != "ROUTE_BASED" || length(var.destination_ranges) > 0
      error_message = "destination_ranges must have at least one entry when routing_mode is ROUTE_BASED."
    }
    precondition {
      condition = var.routing_mode != "POLICY_BASED" || (
        length(var.local_traffic_selector) > 0 &&
        length(var.remote_traffic_selector) > 0 &&
        !contains(var.local_traffic_selector, "0.0.0.0/0") &&
        !contains(var.remote_traffic_selector, "0.0.0.0/0")
      )
      error_message = "local_traffic_selector and remote_traffic_selector must be set to specific CIDRs (not 0.0.0.0/0) when routing_mode is POLICY_BASED -- GCP derives route-based mode from 0.0.0.0/0 selectors regardless of this field."
    }
  }
}

resource "google_compute_route" "this" {
  for_each = var.routing_mode == "ROUTE_BASED" ? toset(var.destination_ranges) : toset([])

  project             = var.project_id
  name                = "${var.name}-route-${replace(replace(each.value, "/", "-"), ".", "-")}"
  network             = var.network
  dest_range          = each.value
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.this.self_link
}
