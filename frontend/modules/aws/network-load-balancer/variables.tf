variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
}

variable "network_load_balancer" {
  description = "Map of Network Load Balancer configurations to deploy, keyed by name."
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
    security_group_description = optional(string, "Security group for Network Load Balancer")
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
        description = "Allow TCP inbound traffic"
        from_port   = 80
        to_port     = 80
        ip_protocol = "tcp"
        cidr_ipv4   = "0.0.0.0/0"
      },
      {
        description = "Allow TLS inbound traffic"
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

    enable_deletion_protection       = optional(bool, false)
    enable_cross_zone_load_balancing = optional(bool, false)
    client_keep_alive                = optional(number, 3600)
    dns_record_client_routing_policy = optional(string, null)

    access_logs = optional(object({
      bucket  = string
      prefix  = optional(string, null)
      enabled = optional(bool, true)
    }), null)

    target_groups = optional(list(object({
      key                    = string
      name                   = optional(string, null)
      name_prefix            = optional(string, null)
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
    })), [])

    target_group_attachments = optional(list(object({
      key               = string
      target_group_key  = string
      target_id         = string
      port              = optional(number, null)
      availability_zone = optional(string, null)
    })), [])

    listeners = optional(list(object({
      key              = string
      port             = number
      protocol         = optional(string, "TCP")
      ssl_policy       = optional(string, null)
      certificate_arn  = optional(string, null)
      alpn_policy      = optional(string, null)
      target_group_key = optional(string, null)
      target_group_arn = optional(string, null)
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

    tags = optional(map(string), {})
  }))
  default = {}
}
