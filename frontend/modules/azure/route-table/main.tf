module "route_table" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/route-table?ref=v0.7.6"
  for_each = var.route_table

  name                          = each.value.name
  resource_group_name           = each.value.resource_group_name
  location                      = each.value.location
  bgp_route_propagation_enabled = each.value.bgp_route_propagation_enabled
  routes                        = each.value.routes
  subnet_ids                    = each.value.subnet_ids
  tags                          = each.value.tags
}
