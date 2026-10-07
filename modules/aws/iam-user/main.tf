################################################################################
# AWS IAM User Resource
################################################################################

resource "aws_iam_user" "this" {
  name                 = var.name
  path                 = var.path
  permissions_boundary = var.permissions_boundary

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

################################################################################
# Group Membership
################################################################################

resource "aws_iam_user_group_membership" "this" {
  count = length(var.groups) > 0 ? 1 : 0

  user   = aws_iam_user.this.name
  groups = var.groups
}

################################################################################
# Managed Policy Attachments
################################################################################

resource "aws_iam_user_policy_attachment" "this" {
  for_each = toset(var.managed_policy_arns)

  user       = aws_iam_user.this.name
  policy_arn = each.value
}
