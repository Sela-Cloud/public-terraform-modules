################################################################################
# AWS Route Table Module Variables
################################################################################

variable "vpc_id" {
  description = "Default VPC ID to apply to all route tables unless overridden at the individual route table level."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to all resources created by this module."
  type        = map(string)
  default     = {}
}

variable "route_tables" {
  description = "Map of route table configurations to create. Keyed by route table identifier."
  type = map(object({
    name             = optional(string, null)
    vpc_id           = optional(string, null)
    propagating_vgws = optional(list(string), [])
    subnets          = optional(list(string), [])
    gateway_id       = optional(string, null)
    routes = optional(map(object({
      destination_cidr_block      = optional(string, null)
      destination_ipv6_cidr_block = optional(string, null)
      destination_prefix_list_id  = optional(string, null)
      carrier_gateway_id          = optional(string, null)
      core_network_arn            = optional(string, null)
      egress_only_gateway_id      = optional(string, null)
      gateway_id                  = optional(string, null)
      local_gateway_id            = optional(string, null)
      nat_gateway_id              = optional(string, null)
      network_interface_id        = optional(string, null)
      transit_gateway_id          = optional(string, null)
      vpc_endpoint_id             = optional(string, null)
      vpc_peering_connection_id   = optional(string, null)
      timeouts = optional(object({
        create = optional(string, null)
        delete = optional(string, null)
      }), null)
    })), {})
    tags = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for rt_key, rt in var.route_tables :
      (rt.vpc_id != null && rt.vpc_id != "") || (var.vpc_id != null && var.vpc_id != "")
    ])
    error_message = "Every route table must specify a 'vpc_id' or a top-level 'vpc_id' must be provided."
  }

  validation {
    condition = alltrue([
      for rt_key, rt in var.route_tables :
      !(rt.gateway_id != null && rt.gateway_id != "" && length(coalesce(rt.subnets, [])) > 0)
    ])
    error_message = "A route table cannot specify both 'subnets' and 'gateway_id' associations simultaneously. AWS requires either subnet associations or a gateway association."
  }

  validation {
    condition = (
      length(flatten([for rt in values(var.route_tables) : coalesce(rt.subnets, [])])) ==
      length(distinct(flatten([for rt in values(var.route_tables) : coalesce(rt.subnets, [])])))
    )
    error_message = "Duplicate subnet IDs detected across route tables. In AWS, each subnet can only be associated with one route table."
  }

  validation {
    condition = alltrue(flatten([
      for rt_key, rt in var.route_tables : [
        for r_key, r in coalesce(rt.routes, {}) : (
          (r.destination_cidr_block != null && r.destination_cidr_block != "" ? 1 : 0) +
          (r.destination_ipv6_cidr_block != null && r.destination_ipv6_cidr_block != "" ? 1 : 0) +
          (r.destination_prefix_list_id != null && r.destination_prefix_list_id != "" ? 1 : 0)
        ) == 1
      ]
    ]))
    error_message = "Each route must specify exactly one destination argument: 'destination_cidr_block', 'destination_ipv6_cidr_block', or 'destination_prefix_list_id'."
  }

  validation {
    condition = alltrue(flatten([
      for rt_key, rt in var.route_tables : [
        for r_key, r in coalesce(rt.routes, {}) : (
          (r.carrier_gateway_id != null && r.carrier_gateway_id != "" ? 1 : 0) +
          (r.core_network_arn != null && r.core_network_arn != "" ? 1 : 0) +
          (r.egress_only_gateway_id != null && r.egress_only_gateway_id != "" ? 1 : 0) +
          (r.gateway_id != null && r.gateway_id != "" ? 1 : 0) +
          (r.local_gateway_id != null && r.local_gateway_id != "" ? 1 : 0) +
          (r.nat_gateway_id != null && r.nat_gateway_id != "" ? 1 : 0) +
          (r.network_interface_id != null && r.network_interface_id != "" ? 1 : 0) +
          (r.transit_gateway_id != null && r.transit_gateway_id != "" ? 1 : 0) +
          (r.vpc_endpoint_id != null && r.vpc_endpoint_id != "" ? 1 : 0) +
          (r.vpc_peering_connection_id != null && r.vpc_peering_connection_id != "" ? 1 : 0)
        ) == 1
      ]
    ]))
    error_message = "Each route must specify exactly one target argument among: 'carrier_gateway_id', 'core_network_arn', 'egress_only_gateway_id', 'gateway_id', 'local_gateway_id', 'nat_gateway_id', 'network_interface_id', 'transit_gateway_id', 'vpc_endpoint_id', or 'vpc_peering_connection_id'."
  }

  validation {
    condition = alltrue([
      for rt_key, rt in var.route_tables :
      length([
        for r in values(coalesce(rt.routes, {})) :
        coalesce(r.destination_cidr_block, r.destination_ipv6_cidr_block, r.destination_prefix_list_id, "")
      ]) ==
      length(distinct([
        for r in values(coalesce(rt.routes, {})) :
        coalesce(r.destination_cidr_block, r.destination_ipv6_cidr_block, r.destination_prefix_list_id, "")
      ]))
    ])
    error_message = "Duplicate route destinations detected within the same route table. Each route within a route table must target a unique destination."
  }
}
