/******************************************
  AWS Route Table Root Module
 *****************************************/

module "route_table" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/route-table?ref=v0.9.14"
  for_each = var.route_table

  vpc_id = each.value.vpc_id

  route_tables = {
    (each.key) = {
      name             = coalesce(each.value.name, each.key)
      propagating_vgws = each.value.propagating_vgws
      subnets          = each.value.subnets
      gateway_id       = each.value.gateway_id
      routes           = each.value.routes
      tags             = each.value.tags
    }
  }

  tags = each.value.tags
}
