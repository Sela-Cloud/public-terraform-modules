output "id" {
  description = "The ID of the Front Door Profile."
  value       = azurerm_cdn_frontdoor_profile.profile.id
}

output "name" {
  description = "The name of the Front Door Profile."
  value       = azurerm_cdn_frontdoor_profile.profile.name
}

output "resource_guid" {
  description = "The UUID of the Front Door Profile."
  value       = azurerm_cdn_frontdoor_profile.profile.resource_guid
}

output "endpoints" {
  description = "A map of created endpoints, including their hostnames."
  value = {
    for k, v in azurerm_cdn_frontdoor_endpoint.endpoint : k => {
      id        = v.id
      name      = v.name
      host_name = v.host_name
    }
  }
}

output "origin_groups" {
  description = "A map of created origin groups and their IDs."
  value = {
    for k, v in azurerm_cdn_frontdoor_origin_group.origin_group : k => {
      id   = v.id
      name = v.name
    }
  }
}

output "profile" {
  description = "The full Azure Front Door Profile resource object."
  value       = azurerm_cdn_frontdoor_profile.profile
}
