resource "google_compute_address" "this" {
  for_each = var.vpn
  project  = var.project_id
  name     = "${each.value.name}-ip"
  region   = each.value.region
}

resource "google_compute_vpn_gateway" "this" {
  for_each    = var.vpn
  project     = var.project_id
  name        = "${each.value.name}-gateway"
  region      = each.value.region
  network     = each.value.network
  description = each.value.description
}

resource "google_compute_forwarding_rule" "esp" {
  for_each    = var.vpn
  project     = var.project_id
  name        = "${each.value.name}-esp"
  region      = each.value.region
  ip_protocol = "ESP"
  ip_address  = google_compute_address.this[each.key].self_link
  target      = google_compute_vpn_gateway.this[each.key].self_link
}

resource "google_compute_forwarding_rule" "udp_500" {
  for_each    = var.vpn
  project     = var.project_id
  name        = "${each.value.name}-udp500"
  region      = each.value.region
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.this[each.key].self_link
  target      = google_compute_vpn_gateway.this[each.key].self_link
}

resource "google_compute_forwarding_rule" "udp_4500" {
  for_each    = var.vpn
  project     = var.project_id
  name        = "${each.value.name}-udp4500"
  region      = each.value.region
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.this[each.key].self_link
  target      = google_compute_vpn_gateway.this[each.key].self_link
}

resource "google_compute_vpn_tunnel" "this" {
  for_each                = var.vpn
  project                 = var.project_id
  name                    = each.value.name
  region                  = each.value.region
  description             = each.value.description
  peer_ip                 = each.value.peer_ip
  shared_secret           = each.value.shared_secret
  ike_version             = each.value.ike_version
  target_vpn_gateway      = google_compute_vpn_gateway.this[each.key].self_link
  local_traffic_selector  = each.value.local_traffic_selector
  remote_traffic_selector = each.value.remote_traffic_selector
  depends_on              = [google_compute_forwarding_rule.esp, google_compute_forwarding_rule.udp_500, google_compute_forwarding_rule.udp_4500]
}
