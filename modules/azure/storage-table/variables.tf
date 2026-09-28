variable "name" {
  description = "(Required) The name of the storage table. Only alphanumeric characters allowed, starting with a letter. Must be between 3 and 63 characters in length. Changing this forces a new resource to be created."
  type        = string
  default     = "mysampletable"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9]{2,62}$", var.name))
    error_message = "Storage Table name must be between 3 and 63 characters, must start with a letter, and contain only alphanumeric characters."
  }
}

variable "storage_account_id" {
  description = "(Required) The ID of the Storage Account in which the Table should be created. Changing this forces a new resource to be created."
  type        = string
  default     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-default/providers/Microsoft.Storage/storageAccounts/storagedefault"

  validation {
    condition     = length(trimspace(var.storage_account_id)) > 0
    error_message = "storage_account_id must not be empty."
  }
}

variable "acl" {
  description = "(Optional) One or more acl blocks defining stored access policies for the Table."
  type = list(object({
    id = string
    access_policy = optional(object({
      permissions = string
      start       = optional(string, null)
      expiry      = optional(string, null)
    }), null)
  }))
  default = []
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
