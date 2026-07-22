resource "google_compute_subnetwork" "this" {
  for_each = var.subnet

  project                    = var.project_id
  name                       = each.value.name
  region                     = each.value.region
  network                    = each.value.network
  ip_cidr_range              = each.value.ip_cidr_range
  description                = each.value.description
  purpose                    = each.value.purpose
  role                       = each.value.role
  private_ip_google_access   = each.value.private_ip_google_access
  private_ipv6_google_access = each.value.private_ipv6_google_access
  stack_type                 = each.value.stack_type
  ipv6_access_type           = each.value.ipv6_access_type
  reserved_internal_range    = each.value.reserved_internal_range

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  dynamic "log_config" {
    for_each = each.value.flow_logs ? [each.value] : []
    content {
      aggregation_interval = log_config.value.flow_logs_aggregation_interval
      flow_sampling        = log_config.value.flow_logs_sampling
      metadata             = log_config.value.flow_logs_metadata
      metadata_fields      = log_config.value.flow_logs_metadata == "CUSTOM_METADATA" ? log_config.value.flow_logs_metadata_fields : null
      filter_expr          = log_config.value.flow_logs_filter_expr
    }
  }
}
