################################################################################
# AWS Elastic IP (EIP) Variables
################################################################################

variable "name" {
  description = "Name to be used on all resources as identifier, applied as the 'Name' tag."
  type        = string
  default     = "eip-default"
}

variable "domain" {
  description = "Indicates if this EIP is for use in VPC ('vpc'). In AWS provider v5+, 'vpc' is the standard domain."
  type        = string
  default     = "vpc"

  validation {
    condition     = var.domain == null || contains(["vpc"], coalesce(var.domain, "vpc"))
    error_message = "The domain value must be 'vpc'."
  }
}

variable "instance" {
  description = "EC2 instance ID to associate with the Elastic IP. Conflicts with network_interface."
  type        = string
  default     = null
}

variable "network_interface" {
  description = "Network interface ID to associate with the Elastic IP. Conflicts with instance."
  type        = string
  default     = null
}

variable "associate_with_private_ip" {
  description = "User-specified primary or secondary private IP address to associate with the Elastic IP address."
  type        = string
  default     = null
}

variable "public_ipv4_pool" {
  description = "EC2 IPv4 address pool identifier or 'amazon'. This option is only available for VPC EIPs."
  type        = string
  default     = null
}

variable "network_border_group" {
  description = "Location from which the IP address is advertised. Use this parameter to limit the address to this location."
  type        = string
  default     = null
}

variable "customer_owned_ipv4_pool" {
  description = "ID of a customer-owned address pool for AWS Outposts."
  type        = string
  default     = null
}

variable "ipam_pool_id" {
  description = "The ID of an IPAM pool which has an Amazon-provided or BYOIP public IPv4 CIDR provisioned to it."
  type        = string
  default     = null
}

variable "address" {
  description = "IP address from an EC2 BYOIP pool. This option is only available for VPC EIPs."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
