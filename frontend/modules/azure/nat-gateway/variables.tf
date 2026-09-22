variable "nat_gateway" {
  description = "Map of Azure NAT Gateway configurations to create."
  type = map(object({
    name                    = optional(string, "ng-default")
    resource_group_name     = optional(string, "rg-default")
    location                = optional(string, "eastus")
    sku_name                = optional(string, "Standard")
    idle_timeout_in_minutes = optional(number, 4)
    zones                   = optional(list(string), [])
    tags                    = optional(map(string), {})
  }))
  default = {}
}
