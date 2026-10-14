variable "name" {
  description = "(Required) The name of the Storage Queue. Must be between 3 and 63 characters long, contain only lowercase alphanumeric characters and hyphens, start and end with an alphanumeric character, and cannot have consecutive hyphens. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.name)) && length(var.name) >= 3 && length(var.name) <= 63 && !can(regex("--", var.name))
    error_message = "Storage Queue name must be between 3 and 63 characters, contain only lowercase alphanumeric characters and hyphens, start and end with an alphanumeric character, and not contain consecutive hyphens."
  }
}

variable "storage_account_id" {
  description = "(Required) The ID of the Storage Account in which the Storage Queue should be created. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = length(trimspace(var.storage_account_id)) > 0
    error_message = "storage_account_id must not be empty."
  }
}

variable "metadata" {
  description = "(Optional) A mapping of metadata which should be assigned to this Storage Queue."
  type        = map(string)
  default     = {}
}

variable "timeouts" {
  description = "(Optional) Custom timeout durations for resource operations."
  type = object({
    create = optional(string, null)
    read   = optional(string, null)
    update = optional(string, null)
    delete = optional(string, null)
  })
  default = {}
}
