variable "name" {
  description = "The name of the share. Must be between 3 and 63 characters and contain only lowercase letters, numbers, and hyphens."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.name)) && length(var.name) >= 3 && length(var.name) <= 63 && !can(regex("--", var.name))
    error_message = "Share name must be between 3 and 63 characters, contain only lowercase letters, numbers, and hyphens, start and end with an alphanumeric character, and not contain consecutive hyphens."
  }
}

variable "storage_account_id" {
  description = "The Resource ID or name of the Storage Account in which the File Share should be created. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = length(trimspace(var.storage_account_id)) > 0
    error_message = "storage_account_id must not be empty."
  }
}

variable "quota" {
  description = "The maximum size of the share, in gigabytes. Must be greater than 0, and less than or equal to 5120 GB (5 TB) for standard accounts or 102400 GB (100 TB) for premium accounts."
  type        = number
  default     = 50

  validation {
    condition     = var.quota > 0 && var.quota <= 102400
    error_message = "quota must be greater than 0 and less than or equal to 102400 GB."
  }
}

variable "access_tier" {
  description = "The access tier of the File Share. Possible values are 'TransactionOptimized', 'Hot', 'Cool', and 'Premium'."
  type        = string
  default     = null

  validation {
    condition     = var.access_tier == null || contains(["TransactionOptimized", "Hot", "Cool", "Premium"], coalesce(var.access_tier, "Hot"))
    error_message = "access_tier must be one of 'TransactionOptimized', 'Hot', 'Cool', or 'Premium'."
  }
}

variable "enabled_protocol" {
  description = "The protocol used for the file share. Possible values are 'SMB' and 'NFS'. Defaults to 'SMB'."
  type        = string
  default     = "SMB"

  validation {
    condition     = contains(["SMB", "NFS"], var.enabled_protocol)
    error_message = "enabled_protocol must be either 'SMB' or 'NFS'."
  }
}

variable "metadata" {
  description = "A mapping of custom name, value pairs for this share."
  type        = map(string)
  default     = {}
}

variable "acl" {
  description = "One or more acl blocks defining stored access policies for the share."
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
