/******************************************
  AWS IAM User Root Module
 *****************************************/

module "iam_user" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/iam-user?ref=v0.8.15"
  for_each = var.iam_user

  name                 = coalesce(each.value.name, each.key)
  path                 = each.value.path
  permissions_boundary = each.value.permissions_boundary
  groups               = each.value.groups
  managed_policy_arns  = each.value.managed_policy_arns
  tags                 = each.value.tags
}
