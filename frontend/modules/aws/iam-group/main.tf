/******************************************
  AWS IAM Group Root Module
 *****************************************/

module "iam_group" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/iam-group?ref=v0.8.4"
  for_each = var.iam_group

  name                = coalesce(each.value.name, each.key)
  path                = each.value.path
  managed_policy_arns = each.value.managed_policy_arns
  users               = each.value.users
}
