################################################################################
# AWS VPC Peering Variables
################################################################################

variable "name" {
  description = "Name identifier for the VPC Peering Connection."
  type        = string
  default     = "vpc-peering"
}

variable "vpc_id" {
  description = "The ID of the requester VPC."
  type        = string
}

variable "peer_vpc_id" {
  description = "The ID of the accepter VPC with which you are creating the VPC Peering Connection."
  type        = string
}

variable "peer_owner_id" {
  description = "The AWS account ID of the owner of the peer VPC. Defaults to current account if null."
  type        = string
  default     = null
}

variable "peer_region" {
  description = "The region of the accepter VPC of the VPC Peering Connection."
  type        = string
  default     = null
}

variable "auto_accept" {
  description = "Accept the peering connection. Note: only valid if both VPCs are in the same AWS account and region."
  type        = bool
  default     = false
}

variable "allow_remote_vpc_dns_resolution" {
  description = "Allow a local VPC to resolve public DNS hostnames to private IP addresses when querying instances in the peer VPC."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
