/******************************************
  AWS Network ACL Root Module
 *****************************************/

module "network_acl" {
  source   = "../../../../modules/aws/network-acl"
  for_each = var.network_acl

  name       = coalesce(each.value.name, each.key)
  vpc_id     = each.value.vpc_id
  subnet_ids = each.value.subnet_ids
  ingress    = each.value.ingress
  egress     = each.value.egress
  tags       = each.value.tags
}
