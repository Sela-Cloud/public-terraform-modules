resource "azurerm_storage_queue" "queue" {
  name               = var.name
  storage_account_id = var.storage_account_id
  metadata           = var.metadata

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
