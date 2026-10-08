################################################################################
# Route 53 Hosted Zone
################################################################################

resource "aws_route53_zone" "this" {
  name              = var.name
  comment           = var.comment
  force_destroy     = var.force_destroy
  delegation_set_id = var.delegation_set_id

  dynamic "vpc" {
    for_each = var.vpc_associations
    content {
      vpc_id     = vpc.value.vpc_id
      vpc_region = vpc.value.vpc_region
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )

  lifecycle {
    precondition {
      condition     = var.delegation_set_id == null || length(var.vpc_associations) == 0
      error_message = "delegation_set_id is only valid for a public hosted zone; a private zone (vpc_associations set) can't use a reusable delegation set."
    }
  }
}
