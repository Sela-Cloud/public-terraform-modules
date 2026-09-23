variable "name" {
  description = "The name of the Application Security Group. Changing this forces a new resource to be created."
  type        = string
  default     = "asg-default"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]*[a-zA-Z0-9_]$", var.name)) && length(var.name) >= 1 && length(var.name) <= 80
    error_message = "Application Security Group name must be between 1 and 80 characters, begin with an alphanumeric character, end with an alphanumeric character or underscore, and contain only alphanumerics, hyphens, periods, or underscores."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Application Security Group. Changing this forces a new resource to be created."
  type        = string
  default     = "rg-default"
}

variable "location" {
  description = "The Azure Region where the Application Security Group should exist. Changing this forces a new resource to be created."
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the Application Security Group."
  type        = map(string)
  default     = {}
}

variable "network_interface_ids" {
  description = "Optional list of Network Interface IDs to associate with this Application Security Group."
  type        = list(string)
  default     = []
}

variable "timeouts" {
  description = "Custom timeout durations for resource operations."
  type = object({
    create = optional(string, null)
    read   = optional(string, null)
    update = optional(string, null)
    delete = optional(string, null)
  })
  default = {}
}
