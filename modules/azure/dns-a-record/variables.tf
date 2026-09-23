variable "name" {
  description = "The name of the DNS A Record. Relative to the zone name, or '@' for the zone apex. Changing this forces a new resource to be created."
  type        = string
  default     = "@"

  validation {
    condition     = can(regex("^(@|[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)*)$", var.name)) && length(var.name) >= 1 && length(var.name) <= 63
    error_message = "DNS A Record name must be '@' or between 1 and 63 characters containing alphanumeric characters, hyphens, or underscores."
  }
}

variable "resource_group_name" {
  description = "The name of the Resource Group in which to create the DNS A Record. Changing this forces a new resource to be created."
  type        = string
  default     = "rg-default"

  validation {
    condition     = length(var.resource_group_name) >= 1 && length(var.resource_group_name) <= 90 && can(regex("^[-\\w\\._\\(\\)]+[^\\.]$", var.resource_group_name))
    error_message = "Resource group name must be between 1 and 90 characters, consist of alphanumerics, underscores, parentheses, hyphens, and periods, and cannot end in a period."
  }
}

variable "zone_name" {
  description = "The name of the DNS Zone in which to create the DNS A Record. Changing this forces a new resource to be created."
  type        = string
  default     = "example.com"

  validation {
    condition     = can(regex("^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,}$", var.zone_name)) && length(var.zone_name) >= 1 && length(var.zone_name) <= 253
    error_message = "zone_name must be a valid DNS domain name between 1 and 253 characters."
  }
}

variable "ttl" {
  description = "The Time To Live (TTL) of the DNS record in seconds."
  type        = number
  default     = 300

  validation {
    condition     = var.ttl >= 1
    error_message = "ttl must be a positive integer greater than or equal to 1."
  }
}

variable "records" {
  description = "List of IPv4 Addresses for this A record. Mutually exclusive with target_resource_id."
  type        = list(string)
  default     = ["10.0.0.1"]
}

variable "target_resource_id" {
  description = "The Azure resource ID of the target object (e.g. Public IP) to create an alias record. Mutually exclusive with records."
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the DNS A Record."
  type        = map(string)
  default     = {}
}
