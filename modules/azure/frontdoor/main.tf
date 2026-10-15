resource "azurerm_cdn_frontdoor_profile" "profile" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  sku_name                 = var.sku_name
  response_timeout_seconds = var.response_timeout_seconds
  tags                     = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  for_each = { for ep in var.endpoints : ep.name => ep }

  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile.id
  enabled                  = try(each.value.enabled, true)
  tags                     = try(each.value.tags, var.tags)
}

resource "azurerm_cdn_frontdoor_origin_group" "origin_group" {
  for_each = { for og in var.origin_groups : og.name => og }

  name                                                      = each.value.name
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.profile.id
  session_affinity_enabled                                  = try(each.value.session_affinity_enabled, false)
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = try(each.value.restore_traffic_time_to_healed_or_new_endpoint_in_minutes, null)

  load_balancing {
    sample_size                        = try(each.value.load_balancing.sample_size, 4)
    successful_samples_required        = try(each.value.load_balancing.successful_samples_required, 3)
    additional_latency_in_milliseconds = try(each.value.load_balancing.additional_latency_in_milliseconds, 50)
  }

  dynamic "health_probe" {
    for_each = try(each.value.health_probe, null) != null ? [each.value.health_probe] : []
    content {
      protocol            = try(health_probe.value.protocol, "Https")
      interval_in_seconds = try(health_probe.value.interval_in_seconds, 100)
      path                = try(health_probe.value.path, "/")
      request_type        = try(health_probe.value.request_type, "HEAD")
    }
  }
}

locals {
  origins = flatten([
    for og in var.origin_groups : [
      for orig in og.origins : merge(orig, {
        origin_group_name = og.name
        key               = "${og.name}-${orig.name}"
      })
    ]
  ])
}

resource "azurerm_cdn_frontdoor_origin" "origin" {
  for_each = { for orig in local.origins : orig.key => orig }

  name                           = each.value.name
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.origin_group[each.value.origin_group_name].id
  enabled                        = try(each.value.enabled, true)
  host_name                      = each.value.host_name
  http_port                      = try(each.value.http_port, 80)
  https_port                     = try(each.value.https_port, 443)
  origin_host_header             = coalesce(try(each.value.origin_host_header, null), each.value.host_name)
  priority                       = try(each.value.priority, 1)
  weight                         = try(each.value.weight, 1000)
  certificate_name_check_enabled = try(each.value.certificate_name_check_enabled, true)
}

resource "azurerm_cdn_frontdoor_route" "route" {
  for_each = { for r in var.routes : r.name => r }

  name                          = each.value.name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.endpoint[each.value.endpoint_name].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group[each.value.origin_group_name].id
  cdn_frontdoor_origin_ids = [
    for orig in local.origins : azurerm_cdn_frontdoor_origin.origin[orig.key].id
    if orig.origin_group_name == each.value.origin_group_name
  ]

  forwarding_protocol    = try(each.value.forwarding_protocol, "HttpsOnly")
  patterns_to_match      = try(each.value.patterns_to_match, ["/*"])
  supported_protocols    = try(each.value.supported_protocols, ["Http", "Https"])
  https_redirect_enabled = try(each.value.https_redirect_enabled, true)
  link_to_default_domain = try(each.value.link_to_default_domain, true)

  dynamic "cache" {
    for_each = try(each.value.cache, null) != null ? [each.value.cache] : []
    content {
      query_string_caching_behavior = try(cache.value.query_string_caching_behavior, "IgnoreQueryString")
      query_strings                 = try(cache.value.query_strings, null)
      compression_enabled           = try(cache.value.compression_enabled, false)
      content_types_to_compress     = try(cache.value.content_types_to_compress, null)
    }
  }
}
