data "google_compute_network" "private" {
  for_each = var.visibility == "private" ? toset(var.private_networks) : toset([])

  project = var.project_id
  name    = each.value
}

resource "google_dns_managed_zone" "this" {
  project     = var.project_id
  name        = var.name
  dns_name    = var.dns_name
  visibility  = var.visibility
  description = var.description
  labels      = var.labels

  dynamic "private_visibility_config" {
    for_each = var.visibility == "private" ? [true] : []
    content {
      dynamic "networks" {
        for_each = data.google_compute_network.private
        content {
          network_url = networks.value.self_link
        }
      }
    }
  }

  dynamic "cloud_logging_config" {
    for_each = var.enable_logging ? [true] : []
    content {
      enable_logging = true
    }
  }
}
