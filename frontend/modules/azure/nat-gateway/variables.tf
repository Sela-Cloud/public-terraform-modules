variable "nat_gateway" {
  description = "Map of Azure NAT Gateway configurations to create."

  type = map(object({
    name                    = string
    resource_group_name     = string
    location                = string
    sku_name                = optional(string, "Standard")
    idle_timeout_in_minutes = optional(number, 4)
    zones                   = optional(list(string), [])
    tags                    = optional(map(string), {})
  }))
}
