# Every gateway gets its own Virtual WAN and hub. That ties their lifetime to the gateway:
# destroying it deletes them, and Azure refuses that while anything else is still attached to the
# hub — another gateway, or a virtual network connection added outside this module.
resource "azurerm_virtual_wan" "this" {
  name                              = var.virtual_wan.name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  type                              = var.virtual_wan.type
  allow_branch_to_branch_traffic    = var.virtual_wan.allow_branch_to_branch_traffic
  disable_vpn_encryption            = var.virtual_wan.disable_vpn_encryption
  office365_local_breakout_category = var.virtual_wan.office365_local_breakout_category
  tags                              = var.tags
}

resource "azurerm_virtual_hub" "this" {
  name                   = var.virtual_hub.name
  resource_group_name    = var.resource_group_name
  location               = var.location
  address_prefix         = var.virtual_hub.address_prefix
  sku                    = var.virtual_hub.sku
  hub_routing_preference = var.virtual_hub.hub_routing_preference
  virtual_wan_id         = azurerm_virtual_wan.this.id
  tags                   = var.tags

  # A hub's router takes most of half an hour to provision.
  timeouts {
    create = "60m"
    update = "60m"
    read   = "5m"
    delete = "60m"
  }
}

resource "azurerm_vpn_gateway" "gateway" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_hub_id      = azurerm_virtual_hub.this.id
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

  timeouts {
    create = "60m"
    update = "60m"
    read   = "5m"
    delete = "60m"
  }

  lifecycle {
    # A cross-variable rule needs Terraform 1.9 as a validation; a precondition gives the same
    # early, named error on the 1.5 floor.
    precondition {
      condition     = var.virtual_wan.type == "Standard" || var.virtual_hub.sku == "Basic"
      error_message = "A Basic virtual WAN can only hold Basic hubs. Use a Standard WAN, or set the hub sku to Basic."
    }
  }

}
