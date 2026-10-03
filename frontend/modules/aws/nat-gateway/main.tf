/******************************************
  AWS NAT Gateway Root Module
 *****************************************/

module "nat_gateway" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/nat-gateway?ref=v0.8.2"
  for_each = var.nat_gateway

  name                               = coalesce(each.value.name, each.key)
  availability_mode                  = each.value.availability_mode
  connectivity_type                  = each.value.connectivity_type
  subnet_id                          = each.value.subnet_id
  allocation_id                      = each.value.allocation_id
  vpc_id                             = each.value.vpc_id
  private_ip                         = each.value.private_ip
  secondary_allocation_ids           = each.value.secondary_allocation_ids
  secondary_private_ip_addresses     = each.value.secondary_private_ip_addresses
  secondary_private_ip_address_count = each.value.secondary_private_ip_address_count
  availability_zone_address          = each.value.availability_zone_address
  tags                               = each.value.tags
}
