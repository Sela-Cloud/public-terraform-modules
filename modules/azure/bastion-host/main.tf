resource "azurerm_bastion_host" "bastion" {
  name                      = var.name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  sku                       = var.sku
  scale_units               = var.sku == "Basic" ? 2 : var.scale_units
  copy_paste_enabled        = var.copy_paste_enabled
  file_copy_enabled         = contains(["Standard", "Premium"], var.sku) ? var.file_copy_enabled : null
  shareable_link_enabled    = contains(["Standard", "Premium"], var.sku) ? var.shareable_link_enabled : null
  tunneling_enabled         = contains(["Standard", "Premium"], var.sku) ? var.tunneling_enabled : null
  ip_connect_enabled        = contains(["Standard", "Premium"], var.sku) ? var.ip_connect_enabled : null
  session_recording_enabled = var.sku == "Premium" ? var.session_recording_enabled : null
  kerberos_enabled          = contains(["Standard", "Premium"], var.sku) ? var.kerberos_enabled : null
  zones                     = var.zones
  tags                      = var.tags

  ip_configuration {
    name                 = var.ip_configuration.name != null ? var.ip_configuration.name : "configuration"
    subnet_id            = var.ip_configuration.subnet_id
    public_ip_address_id = var.ip_configuration.public_ip_address_id
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
