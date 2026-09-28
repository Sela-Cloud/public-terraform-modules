resource "google_compute_subnetwork" "this" {
  project                    = var.project_id
  name                       = var.name
  region                     = var.region
  network                    = var.network
  ip_cidr_range              = var.ip_cidr_range
  description                = var.description
  purpose                    = var.purpose
  role                       = var.role
  private_ip_google_access   = var.private_ip_google_access
  private_ipv6_google_access = var.private_ipv6_google_access
  stack_type                 = var.stack_type
  ipv6_access_type           = var.ipv6_access_type
  reserved_internal_range    = var.reserved_internal_range
  dynamic "secondary_ip_range" {
    for_each = var.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
  dynamic "log_config" {
    for_each = var.flow_logs ? [true] : []
    content {
      aggregation_interval = var.flow_logs_aggregation_interval
      flow_sampling        = var.flow_logs_sampling
      metadata             = var.flow_logs_metadata
      metadata_fields      = var.flow_logs_metadata == "CUSTOM_METADATA" ? var.flow_logs_metadata_fields : null
      filter_expr          = var.flow_logs_filter_expr
    }
  }
}
