variable "name" {
  description = "The name of the DNS Zone. Must be a valid domain name. Changing this forces a new resource to be created."
  type        = string
  default     = "example.com"

  validation {
    condition     = can(regex("^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,}$", var.name)) && length(var.name) >= 1 && length(var.name) <= 253
    error_message = "DNS zone name must be a valid domain name between 1 and 253 characters."
  }
}

variable "resource_group_name" {
  description = "The name of the Resource Group in which to create the DNS Zone. Changing this forces a new resource to be created."
  type        = string
  default     = "rg-default"

  validation {
    condition     = length(var.resource_group_name) >= 1 && length(var.resource_group_name) <= 90 && can(regex("^[-\\w\\._\\(\\)]+[^\\.]$", var.resource_group_name))
    error_message = "Resource group name must be between 1 and 90 characters, consist of alphanumerics, underscores, parentheses, hyphens, and periods, and cannot end in a period."
  }
}

variable "soa_record" {
  description = "Customize details relating to the Start of Authority (SOA) record of the DNS Zone."
  type = object({
    email         = string
    host_name     = optional(string, null)
    expire_time   = optional(number, 2419200)
    minimum_ttl   = optional(number, 300)
    refresh_time  = optional(number, 3600)
    retry_time    = optional(number, 300)
    serial_number = optional(number, 1)
    ttl           = optional(number, 3600)
    tags          = optional(map(string), {})
  })
  default = null
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the DNS Zone."
  type        = map(string)
  default     = {}
}
