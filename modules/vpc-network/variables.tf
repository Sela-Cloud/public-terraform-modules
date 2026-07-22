variable "project_id" {
  description = "The GCP project that owns the VPC networks."
  type        = string
}

variable "vpc_network" {
  description = "VPC network definitions, keyed by network name."
  type = map(object({
    name                                      = string
    description                               = optional(string, "")
    auto_create_subnetworks                   = optional(bool, false)
    routing_mode                              = optional(string, "GLOBAL")
    mtu                                       = optional(number, 1460)
    delete_default_routes_on_create           = optional(bool, false)
    enable_ula_internal_ipv6                  = optional(bool, false)
    internal_ipv6_range                       = optional(string)
    network_firewall_policy_enforcement_order = optional(string, "AFTER_CLASSIC_FIREWALL")
  }))

  validation {
    condition     = alltrue([for network in values(var.vpc_network) : contains(["GLOBAL", "REGIONAL"], network.routing_mode)])
    error_message = "routing_mode must be GLOBAL or REGIONAL."
  }

  validation {
    condition     = alltrue([for network in values(var.vpc_network) : contains(["BEFORE_CLASSIC_FIREWALL", "AFTER_CLASSIC_FIREWALL"], network.network_firewall_policy_enforcement_order)])
    error_message = "network_firewall_policy_enforcement_order must be BEFORE_CLASSIC_FIREWALL or AFTER_CLASSIC_FIREWALL."
  }
}
