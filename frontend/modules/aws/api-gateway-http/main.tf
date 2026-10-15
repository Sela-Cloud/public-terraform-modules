/******************************************
  AWS API Gateway HTTP API Root Module
 *****************************************/

module "api_gateway_http" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/api-gateway-http?ref=v0.9.12"
  for_each = var.api_gateway_http

  name                         = coalesce(each.value.name, each.key)
  description                  = each.value.description
  disable_execute_api_endpoint = each.value.disable_execute_api_endpoint
  cors_configuration           = each.value.cors_configuration

  routes      = each.value.routes
  authorizers = each.value.authorizers

  stage_name                 = each.value.stage_name
  auto_deploy                = each.value.auto_deploy
  access_log_destination_arn = each.value.access_log_destination_arn
  access_log_format          = each.value.access_log_format
  default_route_settings     = each.value.default_route_settings

  create_vpc_link             = each.value.create_vpc_link
  vpc_link_security_group_ids = each.value.vpc_link_security_group_ids
  vpc_link_subnet_ids         = each.value.vpc_link_subnet_ids

  domain_name     = each.value.domain_name
  certificate_arn = each.value.certificate_arn
  security_policy = each.value.security_policy
  api_mapping_key = each.value.api_mapping_key

  tags = each.value.tags
}
