/******************************************
  AWS VPC Endpoint Root Module
 *****************************************/

module "vpc_endpoint" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/vpc-endpoint?ref=v0.9.15"
  for_each = var.vpc_endpoint

  vpc_id                       = each.value.vpc_id
  subnet_ids                   = each.value.subnet_ids
  route_table_ids              = each.value.route_table_ids
  security_group_ids           = each.value.security_group_ids
  endpoints                    = each.value.endpoints
  create_security_group        = each.value.create_security_group
  security_group_name          = each.value.security_group_name
  security_group_description   = each.value.security_group_description
  security_group_ingress_rules = each.value.security_group_ingress_rules
  security_group_egress_rules  = each.value.security_group_egress_rules
  tags                         = each.value.tags
}
