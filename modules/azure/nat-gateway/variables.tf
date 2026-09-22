variable "name" {
  description = "The name of the NAT Gateway. Changing this forces a new resource to be created."
  type        = string
  default     = "ng-default"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]*[a-zA-Z0-9_]$", var.name)) && length(var.name) >= 1 && length(var.name) <= 80
    error_message = "NAT Gateway name must be between 1 and 80 characters, begin with an alphanumeric character, end with an alphanumeric character or underscore, and contain only alphanumerics, hyphens, periods, or underscores."
  }
}

variable "resource_group_name" {
  description = "The name of the Resource Group in which to create the NAT Gateway. Changing this forces a new resource to be created."
  type        = string
  default     = "rg-default"
}

variable "location" {
  description = "The Azure Region where the NAT Gateway should exist. Changing this forces a new resource to be created."
  type        = string
  default     = "eastus"
}

variable "sku_name" {
  description = "The SKU which should be used for the NAT Gateway. At this time the only supported value is 'Standard'."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard"], var.sku_name)
    error_message = "sku_name must be 'Standard'."
  }
}

variable "idle_timeout_in_minutes" {
  description = "The idle timeout in minutes which should be used by this NAT Gateway. Possible values are between 4 and 120 minutes."
  type        = number
  default     = 4

  validation {
    condition     = var.idle_timeout_in_minutes >= 4 && var.idle_timeout_in_minutes <= 120
    error_message = "idle_timeout_in_minutes must be between 4 and 120 minutes."
  }
}

variable "zones" {
  description = "A list of Availability Zones in which this NAT Gateway should be located. Changing this forces a new resource to be created. A Standard NAT Gateway can be deployed to at most one Availability Zone."
  type        = list(string)
  default     = []

  validation {
    condition     = var.zones == null || length(coalesce(var.zones, [])) <= 1
    error_message = "A Standard NAT Gateway can be deployed to at most one Availability Zone."
  }
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the NAT Gateway."
  type        = map(string)
  default     = {}
}
