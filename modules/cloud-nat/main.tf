resource "google_compute_router_nat" "this" {
  for_each                            = var.cloud_nat
  project                             = var.project_id
  name                                = each.value.name
  router                              = each.value.router
  region                              = each.value.region
  nat_ip_allocate_option              = each.value.nat_ip_allocate_option
  nat_ips                             = each.value.nat_ip_allocate_option == "MANUAL_ONLY" ? each.value.nat_ips : null
  drain_nat_ips                       = each.value.nat_ip_allocate_option == "MANUAL_ONLY" ? each.value.drain_nat_ips : null
  source_subnetwork_ip_ranges_to_nat  = each.value.source_subnetwork_ip_ranges_to_nat
  min_ports_per_vm                    = each.value.min_ports_per_vm
  max_ports_per_vm                    = each.value.max_ports_per_vm
  enable_endpoint_independent_mapping = each.value.enable_endpoint_independent_mapping
  enable_dynamic_port_allocation      = each.value.enable_dynamic_port_allocation
  auto_network_tier                   = each.value.nat_ip_allocate_option == "AUTO_ONLY" ? each.value.auto_network_tier : null
  dynamic "subnetwork" {
    for_each = each.value.source_subnetwork_ip_ranges_to_nat == "LIST_OF_SUBNETWORKS" ? each.value.subnetworks : []
    content {
      name                     = subnetwork.value.name
      source_ip_ranges_to_nat  = subnetwork.value.source_ip_ranges_to_nat
      secondary_ip_range_names = subnetwork.value.secondary_ip_range_names
    }
  }
  log_config {
    enable = each.value.log_filter != "OFF"
    filter = each.value.log_filter == "OFF" ? "ERRORS_ONLY" : each.value.log_filter
  }
}
