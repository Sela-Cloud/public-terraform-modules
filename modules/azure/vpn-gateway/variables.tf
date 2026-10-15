variable "name" {
  description = "(Required) The name which should be used for this VPN Gateway. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "The VPN Gateway name must be between 1 and 80 characters, begin with an alphanumeric character, end with an alphanumeric character or underscore, and contain only alphanumerics, underscores, hyphens, or periods."
  }
}

variable "resource_group_name" {
  description = "(Required) The name of the Resource Group in which this VPN Gateway should be created. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "(Required) The Azure location where this VPN Gateway should be created. Changing this forces a new resource to be created."
  type        = string
}

variable "virtual_hub" {
  description = "(Required) The Virtual Hub created for the VPN Gateway, in the gateway's resource group and location."
  type = object({
    name = string
    # The hub's own address space, at least a /24. It must not overlap any network the hub
    # connects to.
    address_prefix         = string
    sku                    = optional(string, "Standard")
    hub_routing_preference = optional(string, "ExpressRoute")
  })

  validation {
    condition = try(
      can(cidrnetmask(var.virtual_hub.address_prefix)) && tonumber(split("/", var.virtual_hub.address_prefix)[1]) <= 24,
      false
    )
    error_message = "virtual_hub address_prefix must be an IPv4 CIDR block of /24 or larger, such as 10.100.0.0/23."
  }

  validation {
    condition     = try(contains(["Basic", "Standard"], var.virtual_hub.sku), false)
    error_message = "virtual_hub sku must be Basic or Standard."
  }

  validation {
    condition     = try(contains(["ExpressRoute", "VpnGateway", "ASPath"], var.virtual_hub.hub_routing_preference), false)
    error_message = "virtual_hub hub_routing_preference must be ExpressRoute, VpnGateway or ASPath."
  }
}

variable "virtual_wan" {
  description = "(Required) The Virtual WAN created for the hub, in the gateway's resource group and location."
  type = object({
    name                              = string
    type                              = optional(string, "Standard")
    allow_branch_to_branch_traffic    = optional(bool, true)
    disable_vpn_encryption            = optional(bool, false)
    office365_local_breakout_category = optional(string, "None")
  })

  validation {
    condition     = try(contains(["Basic", "Standard"], var.virtual_wan.type), false)
    error_message = "virtual_wan type must be Basic or Standard."
  }

  validation {
    condition     = try(contains(["Optimize", "OptimizeAndAllow", "All", "None"], var.virtual_wan.office365_local_breakout_category), false)
    error_message = "virtual_wan office365_local_breakout_category must be Optimize, OptimizeAndAllow, All or None."
  }
}

variable "scale_unit" {
  description = "(Optional) The Scale Unit for this VPN Gateway. Defaults to 1."
  type        = number
  default     = 1

  validation {
    condition     = var.scale_unit >= 1 && var.scale_unit <= 100
    error_message = "The scale_unit must be between 1 and 100."
  }
}

variable "bgp_settings" {
  description = "(Optional) A bgp_settings block for configuring Border Gateway Protocol on the VPN Gateway. Defaults to null."
  type = object({
    asn                   = optional(number, 65515)
    peer_weight           = optional(number, 0)
    instance_0_custom_ips = optional(list(string), [])
    instance_1_custom_ips = optional(list(string), [])
  })
  default = null
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the VPN Gateway. Defaults to {}."
  type        = map(string)
  default     = {}
}
