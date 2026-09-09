/******************************************
  AWS VPC Root Module
 *****************************************/

module "vpc" {
  source   = "../../../../modules/aws/vpc"
  for_each = var.vpc

  name                                 = coalesce(each.value.name, each.key)
  cidr_block                           = each.value.cidr_block
  instance_tenancy                     = each.value.instance_tenancy
  enable_dns_support                   = each.value.enable_dns_support
  enable_dns_hostnames                 = each.value.enable_dns_hostnames
  enable_network_address_usage_metrics = each.value.enable_network_address_usage_metrics
  assign_generated_ipv6_cidr_block     = each.value.assign_generated_ipv6_cidr_block
  ipv6_cidr_block_network_border_group = each.value.ipv6_cidr_block_network_border_group
  tags                                 = each.value.tags
}
