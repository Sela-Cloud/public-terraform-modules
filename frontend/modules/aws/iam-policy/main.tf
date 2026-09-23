/******************************************
  AWS IAM Policy Root Module
 *****************************************/

module "iam_policy" {
  source   = "../../../../modules/aws/iam-policy"
  for_each = var.iam_policy

  name                              = each.value.name_prefix != null ? null : coalesce(each.value.name, each.key)
  name_prefix                       = each.value.name_prefix
  description                       = each.value.description
  path                              = each.value.path
  policy                            = each.value.policy
  delay_after_policy_creation_in_ms = each.value.delay_after_policy_creation_in_ms
  tags                              = each.value.tags
}
