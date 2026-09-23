resource "azurerm_dns_a_record" "dns_a_record" {
  name                = var.name
  resource_group_name = var.resource_group_name
  zone_name           = var.zone_name
  ttl                 = var.ttl
  records             = var.target_resource_id == null ? var.records : null
  target_resource_id  = var.target_resource_id
  tags                = var.tags
}
