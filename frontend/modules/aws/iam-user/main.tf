/******************************************
  AWS IAM User Root Module
 *****************************************/

module "iam_user" {
  source   = "../../../../modules/aws/iam-user"
  for_each = var.iam_user

  name                 = coalesce(each.value.name, each.key)
  path                 = each.value.path
  permissions_boundary = each.value.permissions_boundary
  tags                 = each.value.tags
}
