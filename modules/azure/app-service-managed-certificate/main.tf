resource "azurerm_app_service_managed_certificate" "certificate" {
  custom_hostname_binding_id = var.custom_hostname_binding_id
  tags                       = var.tags

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
