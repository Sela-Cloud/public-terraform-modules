resource "azurerm_function_app_function" "function" {
  name            = var.name
  function_app_id = var.function_app_id
  config_json     = var.config_json
  enabled         = var.enabled
  language        = var.language
  test_data       = var.test_data

  dynamic "file" {
    for_each = var.files
    content {
      name    = file.value.name
      content = file.value.content
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
