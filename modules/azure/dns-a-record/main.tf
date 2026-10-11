resource "azurerm_dns_a_record" "dns_a_record" {
  name                = var.name
  resource_group_name = var.resource_group_name
  zone_name           = var.zone_name
  ttl                 = var.ttl
  records             = var.target_resource_id == null ? var.records : null
  target_resource_id  = var.target_resource_id
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
