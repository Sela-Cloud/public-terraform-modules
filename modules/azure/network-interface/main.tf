resource "azurerm_network_interface" "nic" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  dns_servers                   = length(var.dns_servers) > 0 ? var.dns_servers : null
  edge_zone                     = var.edge_zone
  enable_ip_forwarding          = var.enable_ip_forwarding
  enable_accelerated_networking = var.enable_accelerated_networking
  internal_dns_name_label       = var.internal_dns_name_label
  auxiliary_mode                = var.auxiliary_mode
  auxiliary_sku                 = var.auxiliary_sku
  tags                          = var.tags

  dynamic "ip_configuration" {
    for_each = var.ip_configurations
    content {
      name                                               = ip_configuration.value.name
      subnet_id                                          = ip_configuration.value.subnet_id
      private_ip_address_allocation                      = coalesce(ip_configuration.value.private_ip_address_allocation, "Dynamic")
      private_ip_address                                 = ip_configuration.value.private_ip_address
      private_ip_address_version                          = coalesce(ip_configuration.value.private_ip_address_version, "IPv4")
      public_ip_address_id                               = ip_configuration.value.public_ip_address_id
      primary                                            = coalesce(ip_configuration.value.primary, false)
      gateway_load_balancer_frontend_ip_configuration_id = ip_configuration.value.gateway_load_balancer_frontend_ip_configuration_id
    }
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  count                     = var.network_security_group_id != null ? 1 : 0
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = var.network_security_group_id
}
