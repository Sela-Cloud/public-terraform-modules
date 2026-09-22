resource "azurerm_public_ip" "public_ip" {
  name                    = var.name
  resource_group_name     = var.resource_group_name
  location                = var.location
  allocation_method       = var.allocation_method
  sku                     = var.sku
  sku_tier                = var.sku_tier
  ip_version              = var.ip_version
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
  domain_name_label       = var.domain_name_label
  reverse_fqdn            = var.reverse_fqdn
  zones                   = var.zones != null && length(var.zones) > 0 ? var.zones : null
  ddos_protection_mode    = var.ddos_protection_mode
  ddos_protection_plan_id = var.ddos_protection_plan_id
  edge_zone               = var.edge_zone
  public_ip_prefix_id     = var.public_ip_prefix_id
  ip_tags                 = length(var.ip_tags) > 0 ? var.ip_tags : null
  tags                    = var.tags
}
