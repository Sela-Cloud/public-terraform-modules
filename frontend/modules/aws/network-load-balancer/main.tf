/******************************************
  AWS Network Load Balancer Root Module
 *****************************************/

module "network_load_balancer" {
  source   = "../../../../modules/aws/network-load-balancer"
  for_each = var.network_load_balancer

  name                             = coalesce(each.value.name, each.key)
  internal                         = each.value.internal
  ip_address_type                  = each.value.ip_address_type
  vpc_id                           = each.value.vpc_id
  subnets                          = each.value.subnets
  security_groups                  = each.value.security_groups
  create_security_group            = each.value.create_security_group
  security_group_name              = each.value.security_group_name
  security_group_description       = each.value.security_group_description
  enable_deletion_protection       = each.value.enable_deletion_protection
  enable_cross_zone_load_balancing = each.value.enable_cross_zone_load_balancing
  client_keep_alive                = each.value.client_keep_alive
  dns_record_client_routing_policy = each.value.dns_record_client_routing_policy
  target_groups                    = each.value.target_groups
  listeners                        = each.value.listeners
  tags                             = each.value.tags
}
