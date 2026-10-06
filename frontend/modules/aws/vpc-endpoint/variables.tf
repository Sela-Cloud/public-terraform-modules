variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "vpc_endpoint" {
  description = "Map of VPC Endpoint configurations to deploy, keyed by endpoint name."
  type = map(object({
    vpc_id             = optional(string, null)
    subnet_ids         = optional(list(string), [])
    route_table_ids    = optional(list(string), [])
    security_group_ids = optional(list(string), [])
    endpoints = optional(map(object({
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
    })), {})
    create_security_group      = optional(bool, false)
    security_group_name        = optional(string, null)
    security_group_description = optional(string, "Security group for VPC Interface Endpoints")
    tags                       = optional(map(string), {})
  }))
  default = {}
}
