################################################################################
# AWS IAM Group Resource
################################################################################

resource "aws_iam_group" "this" {
  name = var.name
  path = var.path
}

################################################################################
# AWS IAM Group Policy Attachments
################################################################################

resource "aws_iam_group_policy_attachment" "this" {
  for_each = toset(var.managed_policy_arns)

  group      = aws_iam_group.this.name
  policy_arn = each.value
}

################################################################################
# Group Membership
################################################################################

resource "aws_iam_group_membership" "this" {
  count = length(var.users) > 0 ? 1 : 0

  name  = "${var.name}-membership"
  group = aws_iam_group.this.name
  users = var.users
}
