resource "google_compute_firewall" "this" {
  for_each = var.firewall

  project                 = var.project_id
  name                    = each.value.name
  network                 = each.value.network
  direction               = each.value.direction
  priority                = each.value.priority
  description             = each.value.description
  source_ranges           = each.value.source_ranges
  destination_ranges      = each.value.destination_ranges
  source_tags             = each.value.source_tags
  source_service_accounts = each.value.source_service_accounts
  target_tags             = each.value.target_tags
  target_service_accounts = each.value.target_service_accounts
  disabled                = each.value.disabled

  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  dynamic "deny" {
    for_each = each.value.deny
    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }

  dynamic "log_config" {
    for_each = each.value.enable_logging ? [each.value.logging_metadata] : []
    content {
      metadata = log_config.value
    }
  }
}
