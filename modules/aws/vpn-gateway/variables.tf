variable "name" {
  description = "Name to be used on all resources as identifier, applied as the 'Name' tag."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to attach the Virtual Private Gateway to. Leave null to create a detached gateway."
  type        = string
  default     = null
}

variable "availability_zone" {
  description = "The Availability Zone for the Virtual Private Gateway."
  type        = string
  default     = null
}

variable "amazon_side_asn" {
  description = "The Autonomous System Number (ASN) for the Amazon side of the gateway. If null, AWS assigns the default ASN."
  type        = string
  default     = null
}

variable "route_table_ids" {
  description = "Route tables that this gateway's BGP-learned routes should propagate into. Only relevant for dynamic (BGP) routing -- a static-routes-only VPN connection does not need this."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to all resources created by this module."
  type        = map(string)
  default     = {}
}
