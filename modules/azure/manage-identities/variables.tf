variable "name" {
  description = "The name of the User Assigned Identity. Changing this forces a new identity to be created."
  type        = string
  default     = "uai-default"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]{3,128}$", var.name)) && length(var.name) >= 3 && length(var.name) <= 128
    error_message = "User Assigned Identity name must be between 3 and 128 characters and contain only alphanumeric characters, underscores, and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the Resource Group in which to create the User Assigned Identity. Changing this forces a new identity to be created."
  type        = string
  default     = "rg-default"

  validation {
    condition     = can(regex("^[-\\w\\._\\(\\)]+[^\\.]$", var.resource_group_name)) && length(var.resource_group_name) >= 1 && length(var.resource_group_name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters, contain only alphanumerics, underscores, parentheses, hyphens, and periods, and cannot end in a period."
  }
}

variable "location" {
  description = "The Azure Region where the User Assigned Identity should exist. Changing this forces a new identity to be created."
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the User Assigned Identity."
  type        = map(string)
  default     = {}
}

variable "role_assignments" {
  description = "List of role assignments to grant to this User Assigned Managed Identity."
  type = list(object({
    scope                = string
    role_definition_name = optional(string, null)
    role_definition_id   = optional(string, null)
    description          = optional(string, null)
  }))
  default = []
}
