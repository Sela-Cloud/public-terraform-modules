variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
}

variable "vpc" {
  description = "Map of AWS VPC configurations to deploy, keyed by VPC name."
  type = map(object({
    name                                 = string
    cidr_block                           = optional(string, "10.0.0.0/16")
    instance_tenancy                     = optional(string, "default")
    enable_dns_support                   = optional(bool, true)
    enable_dns_hostnames                 = optional(bool, false)
    enable_network_address_usage_metrics = optional(bool, false)
    assign_generated_ipv6_cidr_block     = optional(bool, false)
    ipv6_cidr_block_network_border_group = optional(string, null)
    tags                                 = optional(map(string), {})
  }))
  default = {}
}
