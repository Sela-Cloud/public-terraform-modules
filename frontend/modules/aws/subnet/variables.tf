variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "subnet" {
  description = "Map of AWS Subnet configurations to deploy, keyed by subnet name."
  type = map(object({
    name                                           = optional(string, "subnet-default")
    vpc_id                                         = optional(string, "")
    cidr_block                                     = optional(string, "10.0.1.0/24")
    availability_zone                              = optional(string, null)
    availability_zone_id                           = optional(string, null)
    map_public_ip_on_launch                        = optional(bool, false)
    assign_ipv6_address_on_creation                = optional(bool, false)
    ipv6_cidr_block                                = optional(string, null)
    ipv6_native                                    = optional(bool, false)
    enable_dns64                                   = optional(bool, false)
    enable_resource_name_dns_a_record_on_launch    = optional(bool, false)
    enable_resource_name_dns_aaaa_record_on_launch = optional(bool, false)
    private_dns_hostname_type_on_launch            = optional(string, null)
    enable_lni_at_device_index                     = optional(number, null)
    tags                                           = optional(map(string), {})
  }))
  default = {
    "subnet-default" = {
      name                                           = "subnet-default"
      vpc_id                                         = ""
      cidr_block                                     = "10.0.1.0/24"
      availability_zone                              = null
      availability_zone_id                           = null
      map_public_ip_on_launch                        = false
      assign_ipv6_address_on_creation                = false
      ipv6_cidr_block                                = null
      ipv6_native                                    = false
      enable_dns64                                   = false
      enable_resource_name_dns_a_record_on_launch    = false
      enable_resource_name_dns_aaaa_record_on_launch = false
      private_dns_hostname_type_on_launch            = null
      enable_lni_at_device_index                     = null
      tags                                           = {}
    }
  }
}
