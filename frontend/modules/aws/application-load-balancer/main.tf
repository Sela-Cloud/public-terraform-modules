/******************************************
  AWS Application Load Balancer Root Module
 *****************************************/

module "application_load_balancer" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/application-load-balancer?ref=v0.9.18"
  for_each = var.application_load_balancer

  name            = each.value.name_prefix == null ? coalesce(each.value.name, each.key) : null
  name_prefix     = each.value.name_prefix
  internal        = each.value.internal
  ip_address_type = each.value.ip_address_type

  vpc_id         = each.value.vpc_id
  subnets        = each.value.subnets
  subnet_mapping = each.value.subnet_mapping

  security_groups              = each.value.security_groups
  create_security_group        = each.value.create_security_group
  security_group_name          = each.value.security_group_name
  security_group_description   = each.value.security_group_description
  security_group_ingress_rules = each.value.security_group_ingress_rules
  security_group_egress_rules  = each.value.security_group_egress_rules

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

  access_logs     = each.value.access_logs
  connection_logs = each.value.connection_logs

  target_groups            = each.value.target_groups
  target_group_attachments = each.value.target_group_attachments
  listeners                = each.value.listeners
  extra_certificates       = each.value.extra_certificates
  listener_rules           = each.value.listener_rules

  waf_web_acl_arn = each.value.waf_web_acl_arn

  tags = each.value.tags
}
