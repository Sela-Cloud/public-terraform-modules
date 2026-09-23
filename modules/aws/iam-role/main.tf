################################################################################
# AWS IAM Role Resource
################################################################################

resource "aws_iam_role" "this" {
  name                  = var.name_prefix == null ? var.name : null
  name_prefix           = var.name_prefix
  assume_role_policy    = var.assume_role_policy
  description           = var.description
  path                  = var.path
  force_detach_policies = var.force_detach_policies
  max_session_duration  = var.max_session_duration
  permissions_boundary  = var.permissions_boundary
  managed_policy_arns   = var.managed_policy_arns

  dynamic "inline_policy" {
    for_each = var.inline_policy
    content {
      name   = inline_policy.value.name
      policy = inline_policy.value.policy
    }
  }

  tags = merge(
    var.tags,
    var.name != null && var.name_prefix == null ? {
      Name = var.name
    } : {}
  )
}
