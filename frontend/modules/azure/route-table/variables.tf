variable "route_table" {
  description = "Map of Azure Route Table configurations to create."
  type = map(object({
    name                          = string
    resource_group_name           = string
    location                      = string
    bgp_route_propagation_enabled = optional(bool, true)
    routes = optional(list(object({
      name                   = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string, null)
    })), [])
    subnet_ids = optional(list(string), [])
    tags       = optional(map(string), {})
  }))
  default = {}
}
