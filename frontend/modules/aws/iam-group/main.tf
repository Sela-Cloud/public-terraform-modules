/******************************************
  AWS IAM Group Root Module
 *****************************************/

module "iam_group" {
  source   = "../../../../modules/aws/iam-group"
  for_each = var.iam_group

  name                = coalesce(each.value.name, each.key)
  path                = each.value.path
  managed_policy_arns = each.value.managed_policy_arns
}
