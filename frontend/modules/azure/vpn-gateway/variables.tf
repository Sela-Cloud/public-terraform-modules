variable "vpn_gateway" {
  description = "Map of Azure VPN Gateway configurations."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    virtual_hub = object({
      name                   = string
      address_prefix         = string
      sku                    = optional(string, "Standard")
      hub_routing_preference = optional(string, "ExpressRoute")
    })
    virtual_wan = object({
      name                              = string
      type                              = optional(string, "Standard")
      allow_branch_to_branch_traffic    = optional(bool, true)
      disable_vpn_encryption            = optional(bool, false)
      office365_local_breakout_category = optional(string, "None")
    })
    scale_unit = optional(number, 1)
    bgp_settings = optional(object({
      asn                   = optional(number, 65515)
      peer_weight           = optional(number, 0)
      instance_0_custom_ips = optional(list(string), [])
      instance_1_custom_ips = optional(list(string), [])
    }), null)
    tags = optional(map(string), {})
  }))
  default = {}
}
