resource "google_dns_record_set" "this" {
  project      = var.project_id
  managed_zone = var.managed_zone
  name         = var.name
  type         = var.type
  ttl          = var.ttl
  rrdatas      = var.routing_policy_type == "none" ? var.rrdatas : null

  dynamic "routing_policy" {
    for_each = var.routing_policy_type == "none" ? [] : [true]
    content {
      health_check = var.routing_health_check

      dynamic "wrr" {
        for_each = var.routing_policy_type == "wrr" ? var.wrr_targets : []
        content {
          weight  = wrr.value.weight
          rrdatas = length(wrr.value.rrdatas) > 0 ? wrr.value.rrdatas : null

          dynamic "health_checked_targets" {
            for_each = length(wrr.value.health_checked_external_endpoints) > 0 ? [wrr.value.health_checked_external_endpoints] : []
            content { external_endpoints = health_checked_targets.value }
          }
        }
      }

      dynamic "geo" {
        for_each = var.routing_policy_type == "geo" ? var.geo_targets : []
        content {
          location = geo.value.location
          rrdatas  = length(geo.value.rrdatas) > 0 ? geo.value.rrdatas : null

          dynamic "health_checked_targets" {
            for_each = length(geo.value.health_checked_external_endpoints) > 0 ? [geo.value.health_checked_external_endpoints] : []
            content { external_endpoints = health_checked_targets.value }
          }
        }
      }
    }
  }
}
