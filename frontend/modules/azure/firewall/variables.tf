variable "firewall" {
  description = "Map of Azure Firewall configurations."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    sku_name            = string
    sku_tier            = string

    ip_configuration = optional(list(object({
      name                 = string
      subnet_id            = optional(string, null)
      public_ip_address_id = optional(string, null)
    })), [])

    management_ip_configuration = optional(object({
      name                 = string
      subnet_id            = string
      public_ip_address_id = string
    }), null)

    virtual_hub = optional(object({
      virtual_hub_id  = string
      public_ip_count = optional(number, 1)
    }), null)

    firewall_policy_id = optional(string, null)
    dns_servers        = optional(list(string), [])
    dns_proxy_enabled  = optional(bool, false)
    threat_intel_mode  = optional(string, "Alert")
    zones              = optional(list(string), [])
    private_ip_ranges  = optional(list(string), null)
    tags               = optional(map(string), {})
  }))
  default = {}
}
