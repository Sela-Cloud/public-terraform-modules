variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
}

variable "vpc_endpoint" {
  description = "Map of VPC Endpoint configurations to deploy, keyed by endpoint name."
  type = map(object({
    name               = optional(string, null)
    vpc_id             = optional(string, null)
    subnet_ids         = optional(list(string), [])
    route_table_ids    = optional(list(string), [])
    security_group_ids = optional(list(string), [])
    endpoints = optional(list(object({
      key                 = string
      service             = optional(string, null)
      service_name        = optional(string, null)
      service_type        = optional(string, "Interface")
      service_region      = optional(string, null)
      private_dns_enabled = optional(bool, null)
      auto_accept         = optional(bool, true)
      route_table_ids     = optional(list(string), null)
      subnet_ids          = optional(list(string), null)
      subnet_configuration = optional(list(object({
        subnet_id = string
        ipv4      = optional(string, null)
        ipv6      = optional(string, null)
      })), null)
      security_group_ids         = optional(list(string), null)
      policy                     = optional(string, null)
      ip_address_type            = optional(string, null)
      resource_configuration_arn = optional(string, null)
      service_network_arn        = optional(string, null)
      dns_options = optional(object({
        dns_record_ip_type                             = optional(string, null)
        private_dns_only_for_inbound_resolver_endpoint = optional(bool, null)
        private_dns_preference                         = optional(string, null)
        private_dns_specified_domains                  = optional(list(string), null)
      }), null)
      timeouts = optional(object({
        create = optional(string, null)
        update = optional(string, null)
        delete = optional(string, null)
      }), null)
      tags = optional(map(string), {})
    })), [])
    create_security_group      = optional(bool, false)
    security_group_name        = optional(string, null)
    security_group_description = optional(string, "Security group for VPC Interface Endpoints")
    security_group_ingress_rules = optional(list(object({
      description                  = optional(string, null)
      from_port                    = optional(number, 443)
      to_port                      = optional(number, 443)
      ip_protocol                  = optional(string, "tcp")
      cidr_ipv4                    = optional(string, "0.0.0.0/0")
      cidr_ipv6                    = optional(string, null)
      referenced_security_group_id = optional(string, null)
      })), [
      {
        description = "Allow HTTPS inbound from within VPC"
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
    tags = optional(map(string), {})
  }))
  default = {}
}
