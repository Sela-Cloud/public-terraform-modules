/******************************************
  AWS VPC Peering Root Module
 *****************************************/

module "vpc_peering" {
  source   = "../../../../modules/aws/vpc-peering"
  for_each = var.vpc_peering

  name                             = coalesce(each.value.name, each.key)
  vpc_id                           = each.value.vpc_id
  peer_vpc_id                      = each.value.peer_vpc_id
  peer_owner_id                    = each.value.peer_owner_id
  peer_region                      = each.value.peer_region
  auto_accept                      = each.value.auto_accept
  allow_remote_vpc_dns_resolution = each.value.allow_remote_vpc_dns_resolution
  tags                             = each.value.tags
}
