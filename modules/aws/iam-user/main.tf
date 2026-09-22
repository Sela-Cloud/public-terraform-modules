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
