variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "application_load_balancer" {
  description = "Map of Application Load Balancer configurations to deploy, keyed by name."
  type = map(object({
    name            = optional(string, null)
    name_prefix     = optional(string, null)
    internal        = optional(bool, false)
    ip_address_type = optional(string, "ipv4")

    vpc_id  = optional(string, null)
    subnets = optional(list(string), [])
    subnet_mapping = optional(list(object({
      subnet_id            = string
      allocation_id        = optional(string, null)
      private_ipv4_address = optional(string, null)
      ipv6_address         = optional(string, null)
    })), [])

    security_groups            = optional(list(string), [])
    create_security_group      = optional(bool, false)
    security_group_name        = optional(string, null)
    security_group_description = optional(string, "Security group for Application Load Balancer")
    security_group_ingress_rules = optional(list(object({
      description                  = optional(string, null)
      from_port                    = optional(number, null)
      to_port                      = optional(number, null)
      ip_protocol                  = optional(string, "tcp")
      cidr_ipv4                    = optional(string, null)
      cidr_ipv6                    = optional(string, null)
      referenced_security_group_id = optional(string, null)
      })), [
      {
        description = "Allow HTTP inbound from all"
        from_port   = 80
        to_port     = 80
        ip_protocol = "tcp"
        cidr_ipv4   = "0.0.0.0/0"
      },
      {
        description = "Allow HTTPS inbound from all"
        from_port   = 443
        to_port     = 443
        ip_protocol = "tcp"
        cidr_ipv4   = "0.0.0.0/0"
      }
    ])
    security_group_egress_rules = optional(list(object({
      description                  = optional(string, null)
      from_port                    = optional(number, null)
      to_port                      = optional(number, null)
      ip_protocol                  = optional(string, "-1")
      cidr_ipv4                    = optional(string, "0.0.0.0/0")
      cidr_ipv6                    = optional(string, null)
      referenced_security_group_id = optional(string, null)
      })), [
      {
        description = "Allow all outbound traffic"
        ip_protocol = "-1"
        cidr_ipv4   = "0.0.0.0/0"
      }
    ])

    idle_timeout                                = optional(number, 60)
    enable_deletion_protection                  = optional(bool, false)
    enable_cross_zone_load_balancing            = optional(bool, true)
    enable_http2                                = optional(bool, true)
    enable_tls_version_and_cipher_suite_headers = optional(bool, false)
    enable_waf_fail_open                        = optional(bool, false)
    enable_xff_client_port                      = optional(bool, false)
    drop_invalid_header_fields                  = optional(bool, false)
    preserve_host_header                        = optional(bool, false)
    client_keep_alive                           = optional(number, 3600)

    access_logs = optional(object({
      bucket  = string
      prefix  = optional(string, null)
      enabled = optional(bool, true)
    }), null)
    connection_logs = optional(object({
      bucket  = string
      prefix  = optional(string, null)
      enabled = optional(bool, true)
    }), null)

    target_groups = optional(list(object({
      key                           = string
      name                          = optional(string, null)
      name_prefix                   = optional(string, null)
      port                          = optional(number, 80)
      protocol                      = optional(string, "HTTP")
      protocol_version              = optional(string, "HTTP1")
      target_type                   = optional(string, "instance")
      vpc_id                        = optional(string, null)
      deregistration_delay          = optional(number, 300)
      slow_start                    = optional(number, 0)
      load_balancing_algorithm_type = optional(string, "round_robin")
      health_check = optional(object({
        enabled             = optional(bool, true)
        path                = optional(string, "/")
        protocol            = optional(string, "HTTP")
        port                = optional(string, "traffic-port")
        interval            = optional(number, 30)
        timeout             = optional(number, 5)
        healthy_threshold   = optional(number, 3)
        unhealthy_threshold = optional(number, 3)
        matcher             = optional(string, "200-299")
      }), {})
      stickiness = optional(object({
        enabled         = optional(bool, false)
        type            = optional(string, "lb_cookie")
        cookie_duration = optional(number, 86400)
        cookie_name     = optional(string, null)
      }), {})
      tags = optional(map(string), {})
    })), [])

    target_group_attachments = optional(list(object({
      key               = string
      target_group_key  = string
      target_id         = string
      port              = optional(number, null)
      availability_zone = optional(string, null)
    })), [])

    listeners = optional(list(object({
      key                 = string
      port                = number
      protocol            = optional(string, "HTTP")
      ssl_policy          = optional(string, null)
      certificate_arn     = optional(string, null)
      alpn_policy         = optional(string, null)
      default_action_type = optional(string, "forward")
      target_group_key    = optional(string, null)
      target_group_arn    = optional(string, null)
      redirect = optional(object({
        port        = optional(string, null)
        protocol    = optional(string, null)
        host        = optional(string, null)
        path        = optional(string, null)
        query       = optional(string, null)
        status_code = string
      }), null)
      fixed_response = optional(object({
        content_type = string
        message_body = optional(string, null)
        status_code  = string
      }), null)
      forward = optional(object({
        target_groups = list(object({
          target_group_key = optional(string, null)
          target_group_arn = optional(string, null)
          weight           = optional(number, 1)
        }))
      }), null)
      tags = optional(map(string), {})
    })), [])

    extra_certificates = optional(list(object({
      key             = string
      listener_key    = string
      certificate_arn = string
    })), [])

    listener_rules = optional(list(object({
      key              = string
      listener_key     = string
      priority         = optional(number, null)
      action_type      = optional(string, "forward")
      target_group_key = optional(string, null)
      target_group_arn = optional(string, null)
      redirect = optional(object({
        port        = optional(string, null)
        protocol    = optional(string, null)
        host        = optional(string, null)
        path        = optional(string, null)
        query       = optional(string, null)
        status_code = string
      }), null)
      fixed_response = optional(object({
        content_type = string
        message_body = optional(string, null)
        status_code  = string
      }), null)
      conditions = optional(object({
        path_patterns        = optional(list(string), [])
        host_headers         = optional(list(string), [])
        http_request_methods = optional(list(string), [])
        source_ips           = optional(list(string), [])
        http_headers = optional(list(object({
          http_header_name = string
          values           = list(string)
        })), [])
        query_strings = optional(list(object({
          key   = optional(string, null)
          value = string
        })), [])
      }), {})
      tags = optional(map(string), {})
    })), [])

    waf_web_acl_arn = optional(string, null)

    tags = optional(map(string), {})
  }))
  default = {}
}
