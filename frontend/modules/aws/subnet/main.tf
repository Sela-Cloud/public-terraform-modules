/******************************************
  AWS Subnet Root Module
 *****************************************/

module "subnet" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/subnet?ref=v0.7.8"
  for_each = var.subnet

  name                                           = coalesce(each.value.name, each.key)
  vpc_id                                         = each.value.vpc_id
  cidr_block                                     = each.value.cidr_block
  availability_zone                              = each.value.availability_zone
  availability_zone_id                           = each.value.availability_zone_id
  map_public_ip_on_launch                        = each.value.map_public_ip_on_launch
  assign_ipv6_address_on_creation                = each.value.assign_ipv6_address_on_creation
  ipv6_cidr_block                                = each.value.ipv6_cidr_block
  ipv6_native                                    = each.value.ipv6_native
  enable_dns64                                   = each.value.enable_dns64
  enable_resource_name_dns_a_record_on_launch    = each.value.enable_resource_name_dns_a_record_on_launch
  enable_resource_name_dns_aaaa_record_on_launch = each.value.enable_resource_name_dns_aaaa_record_on_launch
  private_dns_hostname_type_on_launch            = each.value.private_dns_hostname_type_on_launch
  enable_lni_at_device_index                     = each.value.enable_lni_at_device_index
  tags                                           = each.value.tags
}
