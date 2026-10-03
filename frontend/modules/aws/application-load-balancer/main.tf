/******************************************
  AWS Application Load Balancer Root Module
 *****************************************/

module "application_load_balancer" {
  source   = "../../../../modules/aws/application-load-balancer"
  for_each = var.application_load_balancer

  name                                        = coalesce(each.value.name, each.key)
  internal                                    = each.value.internal
  ip_address_type                             = each.value.ip_address_type
  vpc_id                                      = each.value.vpc_id
  subnets                                     = each.value.subnets
  security_groups                             = each.value.security_groups
  create_security_group                       = each.value.create_security_group
  security_group_name                         = each.value.security_group_name
  security_group_description                  = each.value.security_group_description
  idle_timeout                                = each.value.idle_timeout
  enable_deletion_protection                  = each.value.enable_deletion_protection
  enable_cross_zone_load_balancing            = each.value.enable_cross_zone_load_balancing
  enable_http2                                = each.value.enable_http2
  enable_tls_version_and_cipher_suite_headers = each.value.enable_tls_version_and_cipher_suite_headers
  enable_waf_fail_open                        = each.value.enable_waf_fail_open
  enable_xff_client_port                      = each.value.enable_xff_client_port
  drop_invalid_header_fields                  = each.value.drop_invalid_header_fields
  preserve_host_header                        = each.value.preserve_host_header
  client_keep_alive                           = each.value.client_keep_alive
  waf_web_acl_arn                             = each.value.waf_web_acl_arn
  target_groups                               = each.value.target_groups
  listeners                                   = each.value.listeners
  tags                                        = each.value.tags
}
