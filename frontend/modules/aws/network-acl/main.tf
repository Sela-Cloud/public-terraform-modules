/******************************************
  AWS Network ACL Root Module
 *****************************************/

module "network_acl" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/network-acl?ref=v0.8.13"
  for_each = var.network_acl

  name       = coalesce(each.value.name, each.key)
  vpc_id     = each.value.vpc_id
  subnet_ids = each.value.subnet_ids
  ingress    = each.value.ingress
  egress     = each.value.egress
  tags       = each.value.tags
}
