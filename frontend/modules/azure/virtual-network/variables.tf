variable "virtual_network" {
  description = "Map of Azure Virtual Network configurations to create."
  type = map(object({
    name                           = optional(string, "vnet-default")
    resource_group_name            = optional(string, "rg-default")
    location                       = optional(string, "eastus")
    address_space                  = optional(list(string), ["10.0.0.0/16"])
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
