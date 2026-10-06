variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "network_load_balancer" {
  description = "Map of Network Load Balancer configurations to deploy, keyed by NLB name."
  type = map(object({
    name                             = optional(string, "net-load-balancer")
    internal                         = optional(bool, false)
    ip_address_type                  = optional(string, "ipv4")
    vpc_id                           = optional(string, null)
    subnets                          = optional(list(string), [])
    security_groups                  = optional(list(string), [])
    create_security_group            = optional(bool, false)
    security_group_name              = optional(string, null)
    security_group_description       = optional(string, "Security group for Network Load Balancer")
    enable_deletion_protection       = optional(bool, false)
    enable_cross_zone_load_balancing = optional(bool, false)
    client_keep_alive                = optional(number, 3600)
    dns_record_client_routing_policy = optional(string, null)
    target_groups = optional(map(object({
      name                   = optional(string, null)
      port                   = optional(number, 80)
      protocol               = optional(string, "TCP")
      target_type            = optional(string, "instance")
      vpc_id                 = optional(string, null)
      deregistration_delay   = optional(number, 300)
      preserve_client_ip     = optional(bool, true)
      proxy_protocol_v2      = optional(bool, false)
      connection_termination = optional(bool, false)
      health_check = optional(object({
        enabled             = optional(bool, true)
        protocol            = optional(string, "TCP")
        port                = optional(string, "traffic-port")
        path                = optional(string, null)
        interval            = optional(number, 10)
        timeout             = optional(number, 10)
        healthy_threshold   = optional(number, 3)
        unhealthy_threshold = optional(number, 3)
        matcher             = optional(string, null)
      }), {})
      stickiness = optional(object({
        enabled = optional(bool, false)
        type    = optional(string, "source_ip")
      }), {})
      tags = optional(map(string), {})
    })), {})
    listeners = optional(map(object({
      port             = number
      protocol         = optional(string, "TCP")
      ssl_policy       = optional(string, null)
      certificate_arn  = optional(string, null)
      alpn_policy      = optional(string, null)
      target_group_key = optional(string, null)
      target_group_arn = optional(string, null)
      tags             = optional(map(string), {})
    })), {})
    tags = optional(map(string), {})
  }))
  default = {}
}
