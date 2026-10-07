################################################################################
# Route 53 Record
################################################################################

resource "aws_route53_record" "this" {
  zone_id = var.zone_id
  name    = var.name
  type    = var.type

  ttl     = var.is_alias ? null : var.ttl
  records = var.is_alias ? null : var.records

  set_identifier                   = var.routing_policy_type == "SIMPLE" ? null : var.set_identifier
  health_check_id                  = var.health_check_id
  allow_overwrite                  = var.allow_overwrite
  multivalue_answer_routing_policy = var.routing_policy_type == "MULTIVALUE" ? true : null

  dynamic "alias" {
    for_each = var.is_alias ? [""] : []
    content {
      name                   = var.alias_name
      zone_id                = var.alias_zone_id
      evaluate_target_health = var.alias_evaluate_target_health
    }
  }

  dynamic "weighted_routing_policy" {
    for_each = var.routing_policy_type == "WEIGHTED" ? [""] : []
    content {
      weight = var.weighted_weight
    }
  }

  dynamic "latency_routing_policy" {
    for_each = var.routing_policy_type == "LATENCY" ? [""] : []
    content {
      region = var.latency_region
    }
  }

  dynamic "failover_routing_policy" {
    for_each = var.routing_policy_type == "FAILOVER" ? [""] : []
    content {
      type = var.failover_type
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = var.routing_policy_type == "GEOLOCATION" ? [""] : []
    content {
      continent   = var.geolocation_continent
      country     = var.geolocation_country
      subdivision = var.geolocation_subdivision
    }
  }

  dynamic "geoproximity_routing_policy" {
    for_each = var.routing_policy_type == "GEOPROXIMITY" ? [""] : []
    content {
      aws_region       = var.geoproximity_aws_region
      bias             = var.geoproximity_bias
      local_zone_group = var.geoproximity_local_zone_group

      dynamic "coordinates" {
        for_each = var.geoproximity_latitude != null && var.geoproximity_longitude != null ? [""] : []
        content {
          latitude  = var.geoproximity_latitude
          longitude = var.geoproximity_longitude
        }
      }
    }
  }

  dynamic "cidr_routing_policy" {
    for_each = var.routing_policy_type == "CIDR" ? [""] : []
    content {
      collection_id = var.cidr_collection_id
      location_name = var.cidr_location_name
    }
  }

  lifecycle {
    precondition {
      condition     = var.is_alias || (var.ttl != null && length(var.records) > 0)
      error_message = "ttl and records are required unless is_alias is true."
    }
    precondition {
      condition     = !var.is_alias || (var.alias_name != null && var.alias_zone_id != null)
      error_message = "alias_name and alias_zone_id are required when is_alias is true."
    }
    precondition {
      condition     = var.routing_policy_type == "SIMPLE" || var.set_identifier != null
      error_message = "set_identifier is required for any routing_policy_type other than SIMPLE."
    }
    precondition {
      condition     = var.routing_policy_type != "WEIGHTED" || var.weighted_weight != null
      error_message = "weighted_weight is required when routing_policy_type is WEIGHTED."
    }
    precondition {
      condition     = var.routing_policy_type != "LATENCY" || var.latency_region != null
      error_message = "latency_region is required when routing_policy_type is LATENCY."
    }
    precondition {
      condition     = var.routing_policy_type != "FAILOVER" || var.failover_type != null
      error_message = "failover_type is required when routing_policy_type is FAILOVER."
    }
    precondition {
      condition     = var.routing_policy_type != "CIDR" || (var.cidr_collection_id != null && var.cidr_location_name != null)
      error_message = "cidr_collection_id and cidr_location_name are required when routing_policy_type is CIDR."
    }
    precondition {
      condition     = var.geolocation_subdivision == null || var.geolocation_country == "US"
      error_message = "geolocation_subdivision requires geolocation_country to be 'US'."
    }
  }
}
