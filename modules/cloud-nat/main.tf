resource "google_compute_router_nat" "this" {
  project                             = var.project_id
  name                                = var.name
  router                              = var.router
  region                              = var.region
  nat_ip_allocate_option              = var.nat_ip_allocate_option
  nat_ips                             = var.nat_ip_allocate_option == "MANUAL_ONLY" ? var.nat_ips : null
  drain_nat_ips                       = var.nat_ip_allocate_option == "MANUAL_ONLY" ? var.drain_nat_ips : null
  source_subnetwork_ip_ranges_to_nat  = var.source_subnetwork_ip_ranges_to_nat
  min_ports_per_vm                    = var.min_ports_per_vm
  max_ports_per_vm                    = var.max_ports_per_vm
  enable_endpoint_independent_mapping = var.enable_endpoint_independent_mapping
  enable_dynamic_port_allocation      = var.enable_dynamic_port_allocation
  auto_network_tier                   = var.nat_ip_allocate_option == "AUTO_ONLY" ? var.auto_network_tier : null
  dynamic "subnetwork" {
    for_each = var.source_subnetwork_ip_ranges_to_nat == "LIST_OF_SUBNETWORKS" ? var.subnetworks : []
    content {
      name                     = subnetwork.value.name
      source_ip_ranges_to_nat  = subnetwork.value.source_ip_ranges_to_nat
      secondary_ip_range_names = subnetwork.value.secondary_ip_range_names
    }
  }
  log_config {
    enable = var.log_filter != "OFF"
    filter = var.log_filter == "OFF" ? "ERRORS_ONLY" : var.log_filter
  }
}
