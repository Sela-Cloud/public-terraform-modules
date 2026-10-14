resource "azurerm_local_network_gateway" "gateway" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  gateway_address     = var.gateway_address
  gateway_fqdn        = var.gateway_fqdn
  address_space       = length(var.address_space) > 0 ? var.address_space : null

  dynamic "bgp_settings" {
    for_each = var.bgp_settings != null && var.bgp_settings.bgp_peering_address != null ? [var.bgp_settings] : []
    content {
      asn                 = bgp_settings.value.asn
      bgp_peering_address = bgp_settings.value.bgp_peering_address
      peer_weight         = bgp_settings.value.peer_weight
    }
  }

  tags = var.tags

  timeouts {
    create = "60m"
    update = "60m"
    read   = "5m"
    delete = "60m"
  }
}
