/******************************************
  AWS Network Load Balancer Root Module
 *****************************************/

module "network_load_balancer" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/network-load-balancer?ref=v0.9.15"
  for_each = var.network_load_balancer

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

  enable_deletion_protection       = each.value.enable_deletion_protection
  enable_cross_zone_load_balancing = each.value.enable_cross_zone_load_balancing
  client_keep_alive                = each.value.client_keep_alive
  dns_record_client_routing_policy = each.value.dns_record_client_routing_policy

  access_logs = each.value.access_logs

  target_groups            = each.value.target_groups
  target_group_attachments = each.value.target_group_attachments
  listeners                = each.value.listeners
  extra_certificates       = each.value.extra_certificates

  tags = each.value.tags
}
