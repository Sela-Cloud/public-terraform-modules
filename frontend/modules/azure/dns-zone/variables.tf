variable "dns_zone" {
  description = "Map of Azure DNS Zone configurations to create."
  type = map(object({
    name                = optional(string, "example.com")
    resource_group_name = optional(string, "rg-default")
    soa_record = optional(object({
      email         = string
      host_name     = optional(string, null)
      expire_time   = optional(number, 2419200)
      minimum_ttl   = optional(number, 300)
      refresh_time  = optional(number, 3600)
      retry_time    = optional(number, 300)
      serial_number = optional(number, 1)
      ttl           = optional(number, 3600)
      tags          = optional(map(string), {})
    }), null)
    tags = optional(map(string), {})
  }))
  default = {}
}
