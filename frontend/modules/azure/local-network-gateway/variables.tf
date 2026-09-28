variable "local_network_gateway" {
  description = "Map of Azure Local Network Gateway configurations."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    gateway_address     = optional(string, null)
    gateway_fqdn        = optional(string, null)
    address_space       = optional(list(string), [])
    bgp_settings = optional(object({
      asn                 = optional(number, 65510)
      bgp_peering_address = optional(string, null)
      peer_weight         = optional(number, 0)
    }), null)
    tags = optional(map(string), {})
  }))
  default = {}
}
