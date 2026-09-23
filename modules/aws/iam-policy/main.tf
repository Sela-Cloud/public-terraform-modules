################################################################################
# AWS IAM Policy Resource
################################################################################

resource "aws_iam_policy" "this" {
  name                              = var.name_prefix == null ? var.name : null
  name_prefix                       = var.name_prefix
  description                       = var.description
  path                              = var.path
  policy                            = var.policy
  delay_after_policy_creation_in_ms = var.delay_after_policy_creation_in_ms

  tags = merge(
    var.tags,
    var.name != null && var.name_prefix == null ? {
      Name = var.name
    } : {}
  )
}
