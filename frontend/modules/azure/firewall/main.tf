module "firewall" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/firewall?ref=v0.7.6"
  for_each = var.firewall

  name                        = each.value.name
  resource_group_name         = each.value.resource_group_name
  location                    = each.value.location
  sku_name                    = each.value.sku_name
  sku_tier                    = each.value.sku_tier
  ip_configuration            = each.value.ip_configuration
  management_ip_configuration = each.value.management_ip_configuration
  virtual_hub                 = each.value.virtual_hub
  firewall_policy_id          = each.value.firewall_policy_id
  dns_servers                 = each.value.dns_servers
  dns_proxy_enabled           = each.value.dns_proxy_enabled
  threat_intel_mode           = each.value.threat_intel_mode
  zones                       = each.value.zones
  private_ip_ranges           = each.value.private_ip_ranges
  tags                        = each.value.tags
}
