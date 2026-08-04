data "google_compute_network" "private" {
  for_each = var.visibility == "private" ? toset(var.private_networks) : toset([])

  project = var.project_id
  name    = each.value
}

data "google_compute_network" "peering_target" {
  for_each = var.zone_type == "peering" ? toset([var.peering_target_network]) : toset([])

  project = var.peering_target_project
  name    = each.value
}

resource "google_dns_managed_zone" "this" {
  project     = var.project_id
  name        = var.name
  dns_name    = var.dns_name
  visibility  = var.visibility
  description = var.description
  labels      = var.labels

  dynamic "dnssec_config" {
    for_each = var.dnssec_state != "off" || var.dnssec_non_existence != null || length(var.dnssec_default_key_specs) > 0 ? [true] : []
    content {
      state         = var.dnssec_state
      non_existence = var.dnssec_non_existence

      dynamic "default_key_specs" {
        for_each = var.dnssec_default_key_specs
        content {
          key_type   = default_key_specs.value.key_type
          algorithm  = default_key_specs.value.algorithm
          key_length = default_key_specs.value.key_length
        }
      }
    }
  }

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

  dynamic "forwarding_config" {
    for_each = var.zone_type == "forwarding" ? [true] : []
    content {
      dynamic "target_name_servers" {
        for_each = var.forwarding_targets
        content {
          ipv4_address    = try(trimspace(target_name_servers.value.ipv4_address), "") != "" ? target_name_servers.value.ipv4_address : null
          ipv6_address    = try(trimspace(target_name_servers.value.ipv6_address), "") != "" ? target_name_servers.value.ipv6_address : null
          domain_name     = try(trimspace(target_name_servers.value.domain_name), "") != "" ? target_name_servers.value.domain_name : null
          forwarding_path = target_name_servers.value.forwarding_path
        }
      }
    }
  }

  dynamic "peering_config" {
    for_each = var.zone_type == "peering" ? [true] : []
    content {
      target_network {
        network_url = one(values(data.google_compute_network.peering_target)).self_link
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
