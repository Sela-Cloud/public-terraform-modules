module "load_balancer" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/load-balancer?ref=v0.7.6"
  for_each = var.load_balancer

  name                       = each.value.name
  resource_group_name        = each.value.resource_group_name
  location                   = each.value.location
  frontend_ip_configurations = each.value.frontend_ip_configurations
  sku                        = each.value.sku
  sku_tier                   = each.value.sku_tier
  type                       = each.value.type
  edge_zone                  = each.value.edge_zone
  tags                       = each.value.tags
  backend_pools              = each.value.backend_pools
  health_probes              = each.value.health_probes
  load_balancing_rules       = each.value.load_balancing_rules
  inbound_nat_rules          = each.value.inbound_nat_rules
}
