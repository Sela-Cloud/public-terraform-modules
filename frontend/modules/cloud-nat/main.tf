resource "google_compute_router_nat" "this" {
  for_each                            = var.cloud_nat
  project                             = var.project_id
  name                                = each.value.name
  router                              = each.value.router
  region                              = each.value.region
  nat_ip_allocate_option              = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat  = each.value.source_subnetwork_ip_ranges_to_nat
  min_ports_per_vm                    = each.value.min_ports_per_vm
  max_ports_per_vm                    = each.value.max_ports_per_vm
  enable_endpoint_independent_mapping = each.value.enable_endpoint_independent_mapping
  enable_dynamic_port_allocation      = each.value.enable_dynamic_port_allocation

  log_config {
    enable = each.value.log_filter != "OFF"
    filter = each.value.log_filter == "OFF" ? "ERRORS_ONLY" : each.value.log_filter
  }
}
