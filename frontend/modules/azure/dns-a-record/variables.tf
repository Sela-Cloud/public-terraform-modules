variable "dns_a_record" {
  description = "Map of Azure DNS A Record configurations to create."
  type = map(object({
    name                = string
    resource_group_name = string
    zone_name           = string
    ttl                 = optional(number, 300)
    records             = optional(list(string), ["10.0.0.1"])
    target_resource_id  = optional(string, null)
    tags                = optional(map(string), {})
  }))
  default = {}
}
