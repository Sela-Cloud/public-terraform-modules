/******************************************
  AWS Security Group Root Module
 *****************************************/

module "security_group" {
  source   = "../../../../modules/aws/security-group"
  for_each = var.security_group

  name                   = coalesce(each.value.name, each.key)
  description            = each.value.description
  vpc_id                 = each.value.vpc_id
  revoke_rules_on_delete = each.value.revoke_rules_on_delete
  ingress_rules          = each.value.ingress_rules
  egress_rules           = each.value.egress_rules
  tags                   = each.value.tags
}
