variable "name" {
  description = "The Name which should be used for this Resource Group. Changing this forces a new Resource Group to be created."
  type        = string
  default     = "rg-default"

  validation {
    condition     = can(regex("^[-\\w\\._\\(\\)]+[^\\.]$", var.name)) && length(var.name) >= 1 && length(var.name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters, contain only alphanumerics, underscores, parentheses, hyphens, and periods, and cannot end in a period."
  }
}

variable "location" {
  description = "The Azure Region where the Resource Group should exist. Changing this forces a new Resource Group to be created."
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the Resource Group."
  type        = map(string)
  default     = {}
}

variable "managed_by" {
  description = "The ID of the resource or application that manages this Resource Group."
  type        = string
  default     = null
}
