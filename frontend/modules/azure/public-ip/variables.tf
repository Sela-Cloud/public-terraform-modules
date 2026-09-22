variable "public_ip" {
  description = "Map of Azure Public IP configurations to create."
  type = map(object({
    name                    = optional(string, "pip-default")
    resource_group_name     = optional(string, "rg-default")
    location                = optional(string, "eastus")
    allocation_method       = optional(string, "Static")
    sku                     = optional(string, "Standard")
    sku_tier                = optional(string, "Regional")
    ip_version              = optional(string, "IPv4")
    idle_timeout_in_minutes = optional(number, 4)
    domain_name_label       = optional(string, null)
    reverse_fqdn            = optional(string, null)
    zones                   = optional(list(string), [])
    ddos_protection_mode    = optional(string, "VirtualNetworkInherited")
    ddos_protection_plan_id = optional(string, null)
    edge_zone               = optional(string, null)
    public_ip_prefix_id     = optional(string, null)
    ip_tags                 = optional(map(string), {})
    tags                    = optional(map(string), {})
  }))
  default = {}
}
