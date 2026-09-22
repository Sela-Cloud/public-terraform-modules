resource "azurerm_vpn_gateway" "gateway" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_hub_id      = var.virtual_hub_id
  scale_unit          = var.scale_unit
  tags                = var.tags

  dynamic "bgp_settings" {
    for_each = var.bgp_settings != null ? [var.bgp_settings] : []
    content {
      asn         = bgp_settings.value.asn
      peer_weight = bgp_settings.value.peer_weight

      dynamic "instance_0_bgp_peering_address" {
        for_each = length(bgp_settings.value.instance_0_custom_ips) > 0 ? [1] : []
        content {
          custom_ips = bgp_settings.value.instance_0_custom_ips
        }
      }

      dynamic "instance_1_bgp_peering_address" {
        for_each = length(bgp_settings.value.instance_1_custom_ips) > 0 ? [1] : []
        content {
          custom_ips = bgp_settings.value.instance_1_custom_ips
        }
      }
    }
  }

  dynamic "timeouts" {
    for_each = length(keys(var.timeouts)) > 0 ? [var.timeouts] : []
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}
