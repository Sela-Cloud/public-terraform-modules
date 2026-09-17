resource "google_compute_firewall" "this" {
  project                 = var.project_id
  name                    = var.name
  network                 = var.network
  direction               = var.direction
  priority                = var.priority
  description             = var.description
  source_ranges           = length(var.source_ranges) > 0 ? var.source_ranges : null
  destination_ranges      = length(var.destination_ranges) > 0 ? var.destination_ranges : null
  source_tags             = length(var.source_tags) > 0 ? var.source_tags : null
  source_service_accounts = length(var.source_service_accounts) > 0 ? var.source_service_accounts : null
  target_tags             = length(var.target_tags) > 0 ? var.target_tags : null
  target_service_accounts = length(var.target_service_accounts) > 0 ? var.target_service_accounts : null
  disabled                = var.disabled
  dynamic "allow" {
    for_each = var.allow
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }
  dynamic "deny" {
    for_each = var.deny
    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }
  dynamic "log_config" {
    for_each = var.enable_logging ? [var.logging_metadata] : []
    content { metadata = log_config.value }
  }
}
