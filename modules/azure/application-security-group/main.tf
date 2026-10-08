resource "azurerm_application_security_group" "asg" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

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

resource "azurerm_network_interface_application_security_group_association" "nic_association" {
  for_each                      = toset(var.network_interface_ids)
  network_interface_id          = each.value
  application_security_group_id = azurerm_application_security_group.asg.id
}
