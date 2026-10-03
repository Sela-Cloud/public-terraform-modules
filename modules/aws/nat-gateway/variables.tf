variable "name" {
  description = "Name to be used on all resources as identifier, applied as the 'Name' tag."
  type        = string
  default     = "nat-gateway-default"
}

variable "availability_mode" {
  description = "Specifies whether to create a zonal (single-AZ) or regional (multi-AZ) NAT gateway. Valid values: 'zonal', 'regional'."
  type        = string
  default     = "zonal"

  validation {
    condition     = contains(["zonal", "regional"], var.availability_mode)
    error_message = "The availability_mode value must be either 'zonal' or 'regional'."
  }
}

variable "connectivity_type" {
  description = "Connectivity type for the NAT Gateway. Valid values: 'private', 'public'."
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "private"], var.connectivity_type)
    error_message = "The connectivity_type value must be either 'public' or 'private'."
  }
}

variable "subnet_id" {
  description = "The Subnet ID of the subnet in which to place the NAT Gateway. Required when availability_mode is 'zonal'. Must not be set when availability_mode is 'regional'."
  type        = string
  default     = null
}

variable "allocation_id" {
  description = "The Allocation ID of the Elastic IP address for the NAT Gateway. Required when connectivity_type is 'public' and availability_mode is 'zonal'. Must not be set when availability_mode is 'regional'."
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID where this NAT Gateway will be created. Required when availability_mode is 'regional'. Must not be set when availability_mode is 'zonal'."
  type        = string
  default     = null
}

variable "private_ip" {
  description = "The private IPv4 address to assign to the NAT Gateway (zonal NAT gateways only). If not provided, an address will be automatically assigned."
  type        = string
  default     = null
}

variable "secondary_allocation_ids" {
  description = "A list of secondary allocation EIP IDs for this NAT Gateway (zonal NAT gateways only)."
  type        = list(string)
  default     = []
}

variable "secondary_private_ip_addresses" {
  description = "A list of secondary private IPv4 addresses to assign to the NAT Gateway (zonal NAT gateways only)."
  type        = list(string)
  default     = []
}

variable "secondary_private_ip_address_count" {
  description = "The number of secondary private IPv4 addresses to assign to the NAT Gateway (zonal and private NAT gateways only)."
  type        = number
  default     = null
}

variable "availability_zone_address" {
  description = "Configuration block for Elastic IP addresses and availability zones for regional NAT gateways."
  type = list(object({
    allocation_ids       = list(string)
    availability_zone    = optional(string, null)
    availability_zone_id = optional(string, null)
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
