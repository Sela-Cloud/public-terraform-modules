variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "vpc_peering" {
  description = "Map of AWS VPC Peering connection configurations to deploy, keyed by connection name."
  type = map(object({
    name                            = optional(string, "vpc-peering")
    vpc_id                          = string
    peer_vpc_id                     = string
    peer_owner_id                   = optional(string, null)
    peer_region                     = optional(string, null)
    auto_accept                     = optional(bool, false)
    allow_remote_vpc_dns_resolution = optional(bool, false)
    tags                            = optional(map(string), {})
  }))
  default = {}
}
