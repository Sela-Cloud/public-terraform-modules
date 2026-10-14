resource "aws_internet_gateway" "this" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )

  lifecycle {
    precondition {
      condition     = !var.create_egress_only_gateway || var.vpc_id != null
      error_message = "vpc_id is required when create_egress_only_gateway is true -- an Egress-Only Internet Gateway cannot be created without a VPC to attach it to."
    }
  }
}

resource "aws_egress_only_internet_gateway" "this" {
  count = var.create_egress_only_gateway ? 1 : 0

  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-egress-only"
    }
  )
}
