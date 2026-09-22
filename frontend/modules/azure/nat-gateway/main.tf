module "nat_gateway" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/nat-gateway?ref=v0.7.6"
  for_each = var.nat_gateway

  name                    = each.value.name
  resource_group_name     = each.value.resource_group_name
  location                = each.value.location
  sku_name                = each.value.sku_name
  idle_timeout_in_minutes = each.value.idle_timeout_in_minutes
  zones                   = each.value.zones
  tags                    = each.value.tags
}
