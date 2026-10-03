variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "application_load_balancer" {
  description = "Map of Application Load Balancer configurations to deploy, keyed by ALB name."
  type = map(object({
    name                                        = optional(string, "app-load-balancer")
    internal                                    = optional(bool, false)
    ip_address_type                             = optional(string, "ipv4")
    vpc_id                                      = optional(string, null)
    subnets                                     = optional(list(string), [])
    security_groups                             = optional(list(string), [])
    create_security_group                       = optional(bool, true)
    security_group_name                         = optional(string, null)
    security_group_description                  = optional(string, "Security group for Application Load Balancer")
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
    waf_web_acl_arn                             = optional(string, null)
    target_groups = optional(map(object({
      name                          = optional(string, null)
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
    })), {})
    listeners = optional(map(object({
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
      tags = optional(map(string), {})
    })), {})
    tags = optional(map(string), {})
  }))
  default = {}
}
