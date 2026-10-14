variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "route_table" {
  description = "Map of Route Table configurations to deploy, keyed by route table name."
  type = map(object({
    name             = optional(string, null)
    vpc_id           = optional(string, null)
    propagating_vgws = optional(list(string), [])
    subnets          = optional(list(string), [])
    gateway_id       = optional(string, null)
    routes = optional(list(object({
      key                         = string
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
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}
