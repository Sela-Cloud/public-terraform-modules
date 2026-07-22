resource "google_compute_subnetwork" "this" {
  for_each                 = var.subnet
  project                  = var.project_id
  name                     = each.value.name
  region                   = each.value.region
  network                  = each.value.network
  ip_cidr_range            = each.value.ip_cidr_range
  description              = each.value.description
  private_ip_google_access = each.value.private_ip_google_access

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  dynamic "log_config" {
    for_each = each.value.flow_logs ? [true] : []
    content {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}
