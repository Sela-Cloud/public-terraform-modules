variable "name" {
  description = "The name of the Private Endpoint. Changing this forces a new resource to be created."
  type        = string
  default     = "pe-default"

  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9_.-]*[a-zA-Z0-9_])?$", var.name)) && length(var.name) >= 1 && length(var.name) <= 80
    error_message = "Private Endpoint name must be between 1 and 80 characters, start with an alphanumeric character, end with an alphanumeric character or underscore, and contain only letters, numbers, underscores, periods, and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the Resource Group in which the Private Endpoint should exist. Changing this forces a new resource to be created."
  type        = string
  default     = "rg-default"
}

variable "location" {
  description = "The Azure Region where the Private Endpoint should exist. Changing this forces a new resource to be created."
  type        = string
  default     = "eastus"
}

variable "subnet_id" {
  description = "The ID of the Subnet from which private IP addresses for this Private Endpoint will be allocated. Changing this forces a new resource to be created."
  type        = string
}

variable "custom_network_interface_name" {
  description = "The custom name of the network interface attached to the private endpoint. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "private_service_connection" {
  description = "Configuration block for the private service connection to the target Azure resource or Private Link Service."
  type = object({
    name                              = optional(string, "psc-default")
    private_connection_resource_id    = optional(string, null)
    private_connection_resource_alias = optional(string, null)
    subresource_names                 = optional(list(string), null)
    is_manual_connection              = optional(bool, false)
    request_message                   = optional(string, null)
  })
  default = {
    name                              = "psc-default"
    private_connection_resource_id    = null
    private_connection_resource_alias = null
    subresource_names                 = null
    is_manual_connection              = false
    request_message                   = null
  }
}

variable "private_dns_zone_group" {
  description = "Configuration block for Private DNS Zone Group to automatically manage DNS records for the Private Endpoint."
  type = object({
    name                 = optional(string, "default")
    private_dns_zone_ids = list(string)
  })
  default = null
}

variable "ip_configurations" {
  description = "List of static IP configuration blocks for assigning specific private IP addresses to the Private Endpoint."
  type = list(object({
    name               = string
    private_ip_address = string
    subresource_name   = optional(string, null)
    member_name        = optional(string, null)
  }))
  default = []
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the Private Endpoint."
  type        = map(string)
  default     = {}
}

variable "timeouts" {
  description = "Custom timeout durations for resource operations."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = {}
}
