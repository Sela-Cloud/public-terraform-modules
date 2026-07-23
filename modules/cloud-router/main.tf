resource "google_compute_router" "this" {
  project     = var.project_id
  name        = var.name
  region      = var.region
  network     = var.network
  description = var.description
  bgp {
    asn                = var.asn
    advertise_mode     = var.advertise_mode
    advertised_groups  = var.advertise_mode == "CUSTOM" ? var.advertised_groups : null
    keepalive_interval = var.keepalive_interval
    identifier_range   = var.identifier_range
    dynamic "advertised_ip_ranges" {
      for_each = var.advertise_mode == "CUSTOM" ? var.advertised_ip_ranges : []
      content {
        range       = advertised_ip_ranges.value.range
        description = advertised_ip_ranges.value.description
      }
    }
  }
}
