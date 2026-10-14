resource "aws_vpn_gateway" "this" {
  vpc_id            = var.vpc_id
  availability_zone = var.availability_zone
  amazon_side_asn   = var.amazon_side_asn

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )

  lifecycle {
    precondition {
      condition     = length(var.route_table_ids) == 0 || var.vpc_id != null
      error_message = "vpc_id is required when route_table_ids is set -- route propagation needs the gateway to be attached to a VPC."
    }
  }
}

resource "aws_vpn_gateway_route_propagation" "this" {
  for_each = toset(var.route_table_ids)

  vpn_gateway_id = aws_vpn_gateway.this.id
  route_table_id = each.value
}
