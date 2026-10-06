/******************************************
  AWS VPC Endpoint Root Module
 *****************************************/

module "vpc_endpoint" {
  source   = "../../../../modules/aws/vpc-endpoint"
  for_each = var.vpc_endpoint

  vpc_id                     = each.value.vpc_id
  subnet_ids                 = each.value.subnet_ids
  route_table_ids            = each.value.route_table_ids
  security_group_ids         = each.value.security_group_ids
  endpoints                  = each.value.endpoints
  create_security_group      = each.value.create_security_group
  security_group_name        = each.value.security_group_name
  security_group_description = each.value.security_group_description
  tags                       = each.value.tags
}
