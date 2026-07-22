resource "google_compute_router" "this" {
  for_each    = var.cloud_router
  project     = var.project_id
  name        = each.value.name
  region      = each.value.region
  network     = each.value.network
  description = each.value.description

  bgp {
    asn               = each.value.asn
    advertise_mode    = each.value.advertise_mode
    advertised_groups = each.value.advertise_mode == "CUSTOM" ? each.value.advertised_groups : null

    dynamic "advertised_ip_ranges" {
      for_each = each.value.advertise_mode == "CUSTOM" ? each.value.advertised_ip_ranges : []
      content {
        range       = advertised_ip_ranges.value.range
        description = advertised_ip_ranges.value.description
      }
    }
  }
}
