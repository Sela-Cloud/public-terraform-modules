resource "google_compute_network" "this" {
  for_each = var.vpc_network

  project                                   = var.project_id
  name                                      = each.value.name
  description                               = each.value.description
  auto_create_subnetworks                   = each.value.auto_create_subnetworks
  routing_mode                              = each.value.routing_mode
  mtu                                       = each.value.mtu
  delete_default_routes_on_create           = each.value.delete_default_routes_on_create
  enable_ula_internal_ipv6                  = each.value.enable_ula_internal_ipv6
  internal_ipv6_range                       = each.value.enable_ula_internal_ipv6 ? each.value.internal_ipv6_range : null
  network_firewall_policy_enforcement_order = each.value.network_firewall_policy_enforcement_order
}
