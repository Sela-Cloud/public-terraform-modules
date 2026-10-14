/******************************************
  AWS VPN Gateway Root Module
 *****************************************/

module "vpn_gateway" {
  source   = "../../../../modules/aws/vpn-gateway"
  for_each = var.vpn_gateway

  name              = coalesce(each.value.name, each.key)
  vpc_id            = each.value.vpc_id
  availability_zone = each.value.availability_zone
  amazon_side_asn   = each.value.amazon_side_asn
  route_table_ids   = each.value.route_table_ids
  tags              = each.value.tags
}
