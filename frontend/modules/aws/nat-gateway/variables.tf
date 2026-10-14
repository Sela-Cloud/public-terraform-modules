variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
}

variable "nat_gateway" {
  description = "Map of AWS NAT Gateway configurations to deploy, keyed by NAT gateway name."
  type = map(object({
    name                               = string
    availability_mode                  = optional(string, "zonal")
    connectivity_type                  = optional(string, "public")
    subnet_id                          = optional(string, null)
    allocation_id                      = optional(string, null)
    vpc_id                             = optional(string, null)
    private_ip                         = optional(string, null)
    secondary_allocation_ids           = optional(list(string), [])
    secondary_private_ip_addresses     = optional(list(string), [])
    secondary_private_ip_address_count = optional(number, null)
    availability_zone_address = optional(list(object({
      allocation_ids       = list(string)
      availability_zone    = optional(string, null)
      availability_zone_id = optional(string, null)
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}
