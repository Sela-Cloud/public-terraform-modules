variable "vpn_gateway" {
  description = "Map of Azure VPN Gateway configurations."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    virtual_hub_id      = string
    scale_unit          = optional(number, 1)
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
