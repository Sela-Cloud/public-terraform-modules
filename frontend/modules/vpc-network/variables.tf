variable "project_id" { type = string }
variable "vpc_network" {
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
}
