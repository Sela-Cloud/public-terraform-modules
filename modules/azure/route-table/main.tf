resource "azurerm_route_table" "route_table" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  bgp_route_propagation_enabled = var.bgp_route_propagation_enabled
  tags                          = var.tags

  dynamic "route" {
    for_each = var.routes
    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = route.value.next_hop_type == "VirtualAppliance" ? route.value.next_hop_in_ip_address : null
    }
  }

  timeouts {
    create = "30m"
    update = "30m"
    read   = "5m"
    delete = "30m"
  }
}

resource "azurerm_subnet_route_table_association" "subnet_association" {
  for_each       = toset(var.subnet_ids)
  subnet_id      = each.value
  route_table_id = azurerm_route_table.route_table.id

  timeouts {
    create = "30m"
    read   = "5m"
    delete = "30m"
  }
}
