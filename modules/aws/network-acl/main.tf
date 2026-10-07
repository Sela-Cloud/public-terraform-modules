################################################################################
# AWS Network ACL Resource
################################################################################

resource "aws_network_acl" "this" {
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  dynamic "ingress" {
    for_each = var.ingress
    content {
      rule_no         = ingress.value.rule_no
      action          = ingress.value.action
      protocol        = ingress.value.protocol
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      cidr_block      = ingress.value.cidr_block
      ipv6_cidr_block = ingress.value.ipv6_cidr_block
      icmp_type       = ingress.value.icmp_type
      icmp_code       = ingress.value.icmp_code
    }
  }

  dynamic "egress" {
    for_each = var.egress
    content {
      rule_no         = egress.value.rule_no
      action          = egress.value.action
      protocol        = egress.value.protocol
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      cidr_block      = egress.value.cidr_block
      ipv6_cidr_block = egress.value.ipv6_cidr_block
      icmp_type       = egress.value.icmp_type
      icmp_code       = egress.value.icmp_code
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
      condition     = var.vpc_id != null && var.vpc_id != ""
      error_message = "vpc_id is required."
    }
    precondition {
      condition     = alltrue([for r in var.ingress : (r.cidr_block != null) != (r.ipv6_cidr_block != null)])
      error_message = "Each ingress rule must set exactly one of cidr_block or ipv6_cidr_block."
    }
    precondition {
      condition     = alltrue([for r in var.egress : (r.cidr_block != null) != (r.ipv6_cidr_block != null)])
      error_message = "Each egress rule must set exactly one of cidr_block or ipv6_cidr_block."
    }
    precondition {
      condition     = length(distinct([for r in var.ingress : r.rule_no])) == length(var.ingress)
      error_message = "rule_no must be unique among ingress rules."
    }
    precondition {
      condition     = length(distinct([for r in var.egress : r.rule_no])) == length(var.egress)
      error_message = "rule_no must be unique among egress rules."
    }
  }
}
