variable "virtual_network" {
  description = "Map of Azure Virtual Network configurations to create."
  type = map(object({
    name                           = string
    resource_group_name            = string
    location                       = string
    address_space                  = list(string)
    dns_servers                    = optional(list(string), [])
    bgp_community                  = optional(string, null)
    flow_timeout_in_minutes        = optional(number, null)
    edge_zone                      = optional(string, null)
    private_endpoint_vnet_policies = optional(string, "Disabled")
    ddos_protection_plan = optional(object({
      id     = string
      enable = optional(bool, true)
    }), null)
    encryption = optional(object({
      enforcement = optional(string, "AllowUnencrypted")
    }), null)
    tags = optional(map(string), {})
  }))
  default = {}
}
