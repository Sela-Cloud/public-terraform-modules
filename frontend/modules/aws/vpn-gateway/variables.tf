variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
}

variable "vpn_gateway" {
  description = "Map of Virtual Private Gateway configurations to deploy, keyed by name."
  type = map(object({
    name              = optional(string, null)
    vpc_id            = optional(string, null)
    availability_zone = optional(string, null)
    amazon_side_asn   = optional(string, null)
    route_table_ids   = optional(list(string), [])
    tags              = optional(map(string), {})
  }))
  default = {}
}
