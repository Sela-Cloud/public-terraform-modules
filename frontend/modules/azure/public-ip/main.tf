module "public_ip" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/public-ip?ref=v0.7.6"
  for_each = var.public_ip

  name                    = each.value.name
  resource_group_name     = each.value.resource_group_name
  location                = each.value.location
  allocation_method       = each.value.allocation_method
  sku                     = each.value.sku
  sku_tier                = each.value.sku_tier
  ip_version              = each.value.ip_version
  idle_timeout_in_minutes = each.value.idle_timeout_in_minutes
  domain_name_label       = each.value.domain_name_label
  reverse_fqdn            = each.value.reverse_fqdn
  zones                   = each.value.zones
  ddos_protection_mode    = each.value.ddos_protection_mode
  ddos_protection_plan_id = each.value.ddos_protection_plan_id
  edge_zone               = each.value.edge_zone
  public_ip_prefix_id     = each.value.public_ip_prefix_id
  ip_tags                 = each.value.ip_tags
  tags                    = each.value.tags
}
