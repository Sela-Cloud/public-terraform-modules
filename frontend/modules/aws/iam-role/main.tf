/******************************************
  AWS IAM Role Root Module
 *****************************************/

module "iam_role" {
  source   = "../../../../modules/aws/iam-role"
  for_each = var.iam_role

  name                  = each.value.name_prefix != null ? null : coalesce(each.value.name, each.key)
  name_prefix           = each.value.name_prefix
  assume_role_policy    = each.value.assume_role_policy
  description           = each.value.description
  path                  = each.value.path
  force_detach_policies = each.value.force_detach_policies
  max_session_duration  = each.value.max_session_duration
  permissions_boundary  = each.value.permissions_boundary
  managed_policy_arns   = each.value.managed_policy_arns
  inline_policy         = each.value.inline_policy
  tags                  = each.value.tags
}
