################################################################################
# Locals & Computed Properties
################################################################################

locals {
  security_group_ids = compact(concat(
    var.security_groups,
    try([aws_security_group.this[0].id], [])
  ))
}

################################################################################
# Dedicated Security Group (Supported for AWS NLB)
################################################################################

resource "aws_security_group" "this" {
  count       = var.create_security_group ? 1 : 0
  name        = coalesce(var.security_group_name, "${var.name}-sg")
  description = var.security_group_description
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = coalesce(var.security_group_name, "${var.name}-sg")
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  count = var.create_security_group ? length(var.security_group_ingress_rules) : 0

  security_group_id            = aws_security_group.this[0].id
  description                  = var.security_group_ingress_rules[count.index].description
  from_port                    = var.security_group_ingress_rules[count.index].from_port
  to_port                      = var.security_group_ingress_rules[count.index].to_port
  ip_protocol                  = var.security_group_ingress_rules[count.index].ip_protocol
  cidr_ipv4                    = var.security_group_ingress_rules[count.index].cidr_ipv4
  cidr_ipv6                    = var.security_group_ingress_rules[count.index].cidr_ipv6
  referenced_security_group_id = var.security_group_ingress_rules[count.index].referenced_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  count = var.create_security_group ? length(var.security_group_egress_rules) : 0

  security_group_id            = aws_security_group.this[0].id
  description                  = var.security_group_egress_rules[count.index].description
  from_port                    = var.security_group_egress_rules[count.index].from_port
  to_port                      = var.security_group_egress_rules[count.index].to_port
  ip_protocol                  = var.security_group_egress_rules[count.index].ip_protocol
  cidr_ipv4                    = var.security_group_egress_rules[count.index].cidr_ipv4
  cidr_ipv6                    = var.security_group_egress_rules[count.index].cidr_ipv6
  referenced_security_group_id = var.security_group_egress_rules[count.index].referenced_security_group_id
}

################################################################################
# Network Load Balancer
################################################################################

resource "aws_lb" "this" {
  name        = var.name_prefix == null ? var.name : null
  name_prefix = var.name_prefix

  internal           = var.internal
  load_balancer_type = "network"
  security_groups    = length(local.security_group_ids) > 0 ? local.security_group_ids : null

  subnets = length(var.subnet_mapping) == 0 && length(var.subnets) > 0 ? var.subnets : null

  dynamic "subnet_mapping" {
    for_each = var.subnet_mapping
    content {
      subnet_id            = subnet_mapping.value.subnet_id
      allocation_id        = subnet_mapping.value.allocation_id
      private_ipv4_address = subnet_mapping.value.private_ipv4_address
      ipv6_address         = subnet_mapping.value.ipv6_address
    }
  }

  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  client_keep_alive                = var.client_keep_alive
  dns_record_client_routing_policy = var.dns_record_client_routing_policy
  ip_address_type                  = var.ip_address_type

  dynamic "access_logs" {
    for_each = var.access_logs != null ? [var.access_logs] : []
    content {
      bucket  = access_logs.value.bucket
      prefix  = access_logs.value.prefix
      enabled = try(access_logs.value.enabled, true)
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

################################################################################
# Target Groups
################################################################################

resource "aws_lb_target_group" "this" {
  for_each = var.target_groups

  name        = each.value.name_prefix == null ? coalesce(each.value.name, substr("${var.name}-${each.key}", 0, 32)) : null
  name_prefix = each.value.name_prefix

  port        = try(each.value.port, 80)
  protocol    = try(each.value.protocol, "TCP")
  target_type = try(each.value.target_type, "instance")
  vpc_id      = coalesce(try(each.value.vpc_id, null), var.vpc_id)

  deregistration_delay   = try(each.value.deregistration_delay, 300)
  preserve_client_ip     = try(each.value.preserve_client_ip, true)
  proxy_protocol_v2      = try(each.value.proxy_protocol_v2, false)
  connection_termination = try(each.value.connection_termination, false)

  dynamic "health_check" {
    for_each = try(each.value.health_check, null) != null ? [each.value.health_check] : []
    content {
      enabled             = try(health_check.value.enabled, true)
      protocol            = try(health_check.value.protocol, "TCP")
      port                = try(health_check.value.port, "traffic-port")
      path                = try(health_check.value.path, null)
      interval            = try(health_check.value.interval, 10)
      timeout             = try(health_check.value.timeout, 10)
      healthy_threshold   = try(health_check.value.healthy_threshold, 3)
      unhealthy_threshold = try(health_check.value.unhealthy_threshold, 3)
      matcher             = try(health_check.value.matcher, null)
    }
  }

  dynamic "stickiness" {
    for_each = try(each.value.stickiness.enabled, false) ? [each.value.stickiness] : []
    content {
      enabled = stickiness.value.enabled
      type    = try(stickiness.value.type, "source_ip")
    }
  }

  tags = merge(
    var.tags,
    try(each.value.tags, {}),
    {
      Name = each.value.name_prefix == null ? coalesce(each.value.name, substr("${var.name}-${each.key}", 0, 32)) : each.value.name_prefix
    }
  )
}

################################################################################
# Target Group Attachments
################################################################################

resource "aws_lb_target_group_attachment" "this" {
  for_each = var.target_group_attachments

  target_group_arn  = can(aws_lb_target_group.this[each.value.target_group_key]) ? aws_lb_target_group.this[each.value.target_group_key].arn : each.value.target_group_key
  target_id         = each.value.target_id
  port              = try(each.value.port, null)
  availability_zone = try(each.value.availability_zone, null)
}

################################################################################
# Listeners
################################################################################

resource "aws_lb_listener" "this" {
  for_each = var.listeners

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = try(each.value.protocol, "TCP")
  ssl_policy        = try(each.value.protocol, "TCP") == "TLS" ? coalesce(try(each.value.ssl_policy, null), "ELBSecurityPolicy-TLS13-1-2-2021-06") : null
  certificate_arn   = try(each.value.protocol, "TCP") == "TLS" ? try(each.value.certificate_arn, null) : null
  alpn_policy       = try(each.value.alpn_policy, null)

  default_action {
    type = "forward"
    target_group_arn = try(each.value.forward, null) == null ? (
      can(aws_lb_target_group.this[each.value.target_group_key]) ? aws_lb_target_group.this[each.value.target_group_key].arn : try(each.value.target_group_arn, null)
    ) : null

    dynamic "forward" {
      for_each = try(each.value.forward, null) != null ? [each.value.forward] : []
      content {
        dynamic "target_group" {
          for_each = forward.value.target_groups
          content {
            arn    = can(aws_lb_target_group.this[target_group.value.target_group_key]) ? aws_lb_target_group.this[target_group.value.target_group_key].arn : coalesce(try(target_group.value.target_group_arn, null), target_group.value.arn)
            weight = try(target_group.value.weight, 1)
          }
        }
      }
    }
  }

  tags = merge(
    var.tags,
    try(each.value.tags, {}),
    {
      Name = "${var.name}-listener-${each.key}"
    }
  )
}

################################################################################
# Extra Listener Certificates (SNI for TLS listeners)
################################################################################

resource "aws_lb_listener_certificate" "this" {
  for_each = var.extra_certificates

  listener_arn    = aws_lb_listener.this[each.value.listener_key].arn
  certificate_arn = each.value.certificate_arn
}
