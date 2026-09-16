################################################################################
# AWS VPC Resource
################################################################################

resource "aws_vpc" "this" {
  cidr_block                           = var.cidr_block
  instance_tenancy                     = var.instance_tenancy
  enable_dns_support                   = var.enable_dns_support
  enable_dns_hostnames                 = var.enable_dns_hostnames
  enable_network_address_usage_metrics = var.enable_network_address_usage_metrics

  assign_generated_ipv6_cidr_block     = var.assign_generated_ipv6_cidr_block
  ipv6_cidr_block_network_border_group = var.ipv6_cidr_block_network_border_group

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}
