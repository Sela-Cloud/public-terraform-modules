module "policy_definition" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/policy-definition?ref=v0.7.6"
  for_each = var.policy_definition

  name                = each.value.name
  display_name        = each.value.display_name
  policy_type         = each.value.policy_type
  mode                = each.value.mode
  description         = each.value.description
  management_group_id = each.value.management_group_id
  policy_rule         = each.value.policy_rule
  parameters          = each.value.parameters
  metadata            = each.value.metadata
}
