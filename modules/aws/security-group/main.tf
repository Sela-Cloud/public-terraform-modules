################################################################################
# AWS Security Group Resource
################################################################################

resource "aws_security_group" "this" {
  name                   = var.name
  description            = var.description
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = var.revoke_rules_on_delete

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )

  lifecycle {
    precondition {
      condition = alltrue([
        for r in var.ingress_rules :
        length(compact([r.cidr_ipv4, r.cidr_ipv6, r.referenced_security_group_id])) == 1
      ])
      error_message = "Each ingress_rules entry must set exactly one of cidr_ipv4, cidr_ipv6, or referenced_security_group_id."
    }
    precondition {
      condition = alltrue([
        for r in var.egress_rules :
        length(compact([r.cidr_ipv4, r.cidr_ipv6, r.referenced_security_group_id])) == 1
      ])
      error_message = "Each egress_rules entry must set exactly one of cidr_ipv4, cidr_ipv6, or referenced_security_group_id."
    }
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  count = length(var.ingress_rules)

  security_group_id            = aws_security_group.this.id
  description                  = var.ingress_rules[count.index].description
  from_port                    = var.ingress_rules[count.index].from_port
  to_port                      = var.ingress_rules[count.index].to_port
  ip_protocol                  = var.ingress_rules[count.index].ip_protocol
  cidr_ipv4                    = var.ingress_rules[count.index].cidr_ipv4
  cidr_ipv6                    = var.ingress_rules[count.index].cidr_ipv6
  referenced_security_group_id = var.ingress_rules[count.index].referenced_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  count = length(var.egress_rules)

  security_group_id            = aws_security_group.this.id
  description                  = var.egress_rules[count.index].description
  from_port                    = var.egress_rules[count.index].from_port
  to_port                      = var.egress_rules[count.index].to_port
  ip_protocol                  = var.egress_rules[count.index].ip_protocol
  cidr_ipv4                    = var.egress_rules[count.index].cidr_ipv4
  cidr_ipv6                    = var.egress_rules[count.index].cidr_ipv6
  referenced_security_group_id = var.egress_rules[count.index].referenced_security_group_id
}
