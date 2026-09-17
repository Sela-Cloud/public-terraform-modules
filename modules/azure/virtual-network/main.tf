resource "azurerm_virtual_network" "vnet" {
  name                           = var.name
  resource_group_name            = var.resource_group_name
  location                       = var.location
  address_space                  = var.address_space
  dns_servers                    = length(var.dns_servers) > 0 ? var.dns_servers : null
  bgp_community                  = var.bgp_community
  flow_timeout_in_minutes        = var.flow_timeout_in_minutes
  edge_zone                      = var.edge_zone
  private_endpoint_vnet_policies = var.private_endpoint_vnet_policies
  tags                           = var.tags

  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan != null ? [var.ddos_protection_plan] : []
    content {
      id     = ddos_protection_plan.value.id
      enable = coalesce(ddos_protection_plan.value.enable, true)
    }
  }

  dynamic "encryption" {
    for_each = var.encryption != null ? [var.encryption] : []
    content {
      enforcement = coalesce(encryption.value.enforcement, "AllowUnencrypted")
    }
  }
}
