variable "name" {
  description = "Name to be used on all resources as identifier, applied as the 'Name' tag."
  type        = string
  default     = "internet-gateway-default"
}

variable "vpc_id" {
  description = "VPC ID to attach the Internet Gateway to. Leave null to create a detached gateway."
  type        = string
  default     = null
}

variable "create_egress_only_gateway" {
  description = "Also create an Egress-Only Internet Gateway (IPv6 outbound-only) attached to the same VPC. Requires vpc_id to be set."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to all resources created by this module."
  type        = map(string)
  default     = {}
}
