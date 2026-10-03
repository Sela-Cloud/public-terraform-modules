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
# Dedicated Security Group
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
# Application Load Balancer
################################################################################

resource "aws_lb" "this" {
  name        = var.name_prefix == null ? var.name : null
  name_prefix = var.name_prefix

  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = local.security_group_ids

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

  idle_timeout                                = var.idle_timeout
  enable_deletion_protection                  = var.enable_deletion_protection
  enable_cross_zone_load_balancing            = var.enable_cross_zone_load_balancing
  enable_http2                                = var.enable_http2
  enable_tls_version_and_cipher_suite_headers = var.enable_tls_version_and_cipher_suite_headers
  enable_waf_fail_open                        = var.enable_waf_fail_open
  enable_xff_client_port                      = var.enable_xff_client_port
  ip_address_type                             = var.ip_address_type
  drop_invalid_header_fields                  = var.drop_invalid_header_fields
  preserve_host_header                        = var.preserve_host_header
  client_keep_alive                           = var.client_keep_alive

  dynamic "access_logs" {
    for_each = var.access_logs != null ? [var.access_logs] : []
    content {
      bucket  = access_logs.value.bucket
      prefix  = access_logs.value.prefix
      enabled = try(access_logs.value.enabled, true)
    }
  }

  dynamic "connection_logs" {
    for_each = var.connection_logs != null ? [var.connection_logs] : []
    content {
      bucket  = connection_logs.value.bucket
      prefix  = connection_logs.value.prefix
      enabled = try(connection_logs.value.enabled, true)
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

  port             = try(each.value.target_type, "instance") == "lambda" ? null : try(each.value.port, 80)
  protocol         = try(each.value.target_type, "instance") == "lambda" ? null : try(each.value.protocol, "HTTP")
  protocol_version = try(each.value.target_type, "instance") == "lambda" ? null : try(each.value.protocol_version, "HTTP1")
  target_type      = try(each.value.target_type, "instance")
  vpc_id           = try(each.value.target_type, "instance") == "lambda" ? null : coalesce(try(each.value.vpc_id, null), var.vpc_id)

  deregistration_delay          = try(each.value.deregistration_delay, 300)
  slow_start                    = try(each.value.slow_start, 0)
  load_balancing_algorithm_type = try(each.value.load_balancing_algorithm_type, "round_robin")

  dynamic "health_check" {
    for_each = try(each.value.health_check, null) != null ? [each.value.health_check] : []
    content {
      enabled             = try(health_check.value.enabled, true)
      path                = try(health_check.value.path, "/")
      protocol            = try(health_check.value.protocol, "HTTP")
      port                = try(health_check.value.port, "traffic-port")
      interval            = try(health_check.value.interval, 30)
      timeout             = try(health_check.value.timeout, 5)
      healthy_threshold   = try(health_check.value.healthy_threshold, 3)
      unhealthy_threshold = try(health_check.value.unhealthy_threshold, 3)
      matcher             = try(health_check.value.matcher, "200-299")
    }
  }

  dynamic "stickiness" {
    for_each = try(each.value.stickiness.enabled, false) ? [each.value.stickiness] : []
    content {
      enabled         = stickiness.value.enabled
      type            = stickiness.value.type
      cookie_duration = try(stickiness.value.cookie_duration, 86400)
      cookie_name     = try(stickiness.value.cookie_name, null)
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

  target_group_arn = can(aws_lb_target_group.this[each.value.target_group_key]) ? aws_lb_target_group.this[each.value.target_group_key].arn : each.value.target_group_key
  target_id        = each.value.target_id
  port             = try(each.value.port, null)
  availability_zone = try(each.value.availability_zone, null)
}

################################################################################
# Listeners
################################################################################

resource "aws_lb_listener" "this" {
  for_each = var.listeners

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = try(each.value.protocol, "HTTP")
  ssl_policy        = try(each.value.protocol, "HTTP") == "HTTPS" ? coalesce(try(each.value.ssl_policy, null), "ELBSecurityPolicy-TLS13-1-2-2021-06") : null
  certificate_arn   = try(each.value.protocol, "HTTP") == "HTTPS" ? try(each.value.certificate_arn, null) : null
  alpn_policy       = try(each.value.alpn_policy, null)

  default_action {
    type = try(each.value.default_action_type, "forward")
    target_group_arn = try(each.value.default_action_type, "forward") == "forward" && try(each.value.forward, null) == null ? (
      can(aws_lb_target_group.this[each.value.target_group_key]) ? aws_lb_target_group.this[each.value.target_group_key].arn : try(each.value.target_group_arn, null)
    ) : null

    dynamic "forward" {
      for_each = try(each.value.forward, null) != null ? [each.value.forward] : []
      content {
        dynamic "target_group" {
          for_each = forward.value.target_groups
          content {
            arn = can(aws_lb_target_group.this[target_group.value.target_group_key]) ? aws_lb_target_group.this[target_group.value.target_group_key].arn : coalesce(try(target_group.value.target_group_arn, null), target_group.value.arn)
            weight = try(target_group.value.weight, 1)
          }
        }
      }
    }

    dynamic "redirect" {
      for_each = try(each.value.redirect, null) != null ? [each.value.redirect] : []
      content {
        port        = redirect.value.port
        protocol    = redirect.value.protocol
        host        = redirect.value.host
        path        = redirect.value.path
        query       = redirect.value.query
        status_code = redirect.value.status_code
      }
    }

    dynamic "fixed_response" {
      for_each = try(each.value.fixed_response, null) != null ? [each.value.fixed_response] : []
      content {
        content_type = fixed_response.value.content_type
        message_body = fixed_response.value.message_body
        status_code  = fixed_response.value.status_code
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
# Extra Listener Certificates (SNI)
################################################################################

resource "aws_lb_listener_certificate" "this" {
  for_each = var.extra_certificates

  listener_arn    = aws_lb_listener.this[each.value.listener_key].arn
  certificate_arn = each.value.certificate_arn
}

################################################################################
# Listener Rules
################################################################################

resource "aws_lb_listener_rule" "this" {
  for_each = var.listener_rules

  listener_arn = aws_lb_listener.this[each.value.listener_key].arn
  priority     = try(each.value.priority, null)

  action {
    type = try(each.value.action_type, "forward")
    target_group_arn = try(each.value.action_type, "forward") == "forward" && try(each.value.redirect, null) == null && try(each.value.fixed_response, null) == null ? (
      can(aws_lb_target_group.this[each.value.target_group_key]) ? aws_lb_target_group.this[each.value.target_group_key].arn : try(each.value.target_group_arn, null)
    ) : null

    dynamic "redirect" {
      for_each = try(each.value.redirect, null) != null ? [each.value.redirect] : []
      content {
        port        = redirect.value.port
        protocol    = redirect.value.protocol
        host        = redirect.value.host
        path        = redirect.value.path
        query       = redirect.value.query
        status_code = redirect.value.status_code
      }
    }

    dynamic "fixed_response" {
      for_each = try(each.value.fixed_response, null) != null ? [each.value.fixed_response] : []
      content {
        content_type = fixed_response.value.content_type
        message_body = fixed_response.value.message_body
        status_code  = fixed_response.value.status_code
      }
    }
  }

  dynamic "condition" {
    for_each = try(length(each.value.conditions.path_patterns) > 0 ? [1] : [], [])
    content {
      path_pattern {
        values = each.value.conditions.path_patterns
      }
    }
  }

  dynamic "condition" {
    for_each = try(length(each.value.conditions.host_headers) > 0 ? [1] : [], [])
    content {
      host_header {
        values = each.value.conditions.host_headers
      }
    }
  }

  dynamic "condition" {
    for_each = try(length(each.value.conditions.http_request_methods) > 0 ? [1] : [], [])
    content {
      http_request_method {
        values = each.value.conditions.http_request_methods
      }
    }
  }

  dynamic "condition" {
    for_each = try(length(each.value.conditions.source_ips) > 0 ? [1] : [], [])
    content {
      source_ip {
        values = each.value.conditions.source_ips
      }
    }
  }

  dynamic "condition" {
    for_each = try(each.value.conditions.http_headers, [])
    content {
      http_header {
        http_header_name = condition.value.http_header_name
        values           = condition.value.values
      }
    }
  }

  dynamic "condition" {
    for_each = try(each.value.conditions.query_strings, [])
    content {
      query_string {
        key   = try(condition.value.key, null)
        value = condition.value.value
      }
    }
  }

  tags = merge(
    var.tags,
    try(each.value.tags, {}),
    {
      Name = "${var.name}-rule-${each.key}"
    }
  )
}

################################################################################
# WAF Web ACL Association
################################################################################

resource "aws_wafv2_web_acl_association" "this" {
  count = var.waf_web_acl_arn != null ? 1 : 0

  resource_arn = aws_lb.this.arn
  web_acl_arn  = var.waf_web_acl_arn
}
