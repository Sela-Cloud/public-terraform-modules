/******************************************
  AWS Internet Gateway Root Module
 *****************************************/

module "internet_gateway" {
  source   = "../../../../modules/aws/internet-gateway"
  for_each = var.internet_gateway

  name                       = coalesce(each.value.name, each.key)
  vpc_id                     = each.value.vpc_id
  create_egress_only_gateway = each.value.create_egress_only_gateway
  tags                       = each.value.tags
}
