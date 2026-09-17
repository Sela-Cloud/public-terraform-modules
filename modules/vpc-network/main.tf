resource "google_compute_network" "this" {
  project                                   = var.project_id
  name                                      = var.name
  description                               = var.description
  auto_create_subnetworks                   = var.auto_create_subnetworks
  routing_mode                              = var.routing_mode
  mtu                                       = var.mtu
  delete_default_routes_on_create           = var.delete_default_routes_on_create
  enable_ula_internal_ipv6                  = var.enable_ula_internal_ipv6
  internal_ipv6_range                       = var.enable_ula_internal_ipv6 ? var.internal_ipv6_range : null
  network_firewall_policy_enforcement_order = var.network_firewall_policy_enforcement_order
}
