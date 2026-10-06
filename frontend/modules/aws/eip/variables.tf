variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "eip" {
  description = "Map of AWS Elastic IP configurations to deploy, keyed by Elastic IP name."
  type = map(object({
    name                      = optional(string, "eip-default")
    domain                    = optional(string, "vpc")
    instance                  = optional(string, null)
    network_interface         = optional(string, null)
    associate_with_private_ip = optional(string, null)
    public_ipv4_pool          = optional(string, null)
    network_border_group      = optional(string, null)
    customer_owned_ipv4_pool  = optional(string, null)
    ipam_pool_id              = optional(string, null)
    address                   = optional(string, null)
    timeouts = optional(object({
      read   = optional(string, null)
      update = optional(string, null)
      delete = optional(string, null)
    }), {})
    tags = optional(map(string), {})
  }))

  validation {
    condition = alltrue([
      for k, v in var.eip : !(v.instance != null && v.network_interface != null)
    ])
    error_message = "Each Elastic IP configuration can specify either 'instance' or 'network_interface', not both."
  }

  default = {
    "eip-default" = {
      name                      = "eip-default"
      domain                    = "vpc"
      instance                  = null
      network_interface         = null
      associate_with_private_ip = null
      public_ipv4_pool          = null
      network_border_group      = null
      customer_owned_ipv4_pool  = null
      ipam_pool_id              = null
      address                   = null
      timeouts                  = {}
      tags                      = {}
    }
  }
}
