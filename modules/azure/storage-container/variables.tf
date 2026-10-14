variable "name" {
  description = "The name of the Container which should be created within the Storage Account. Must be between 3 and 63 characters and contain only lowercase letters, numbers, and hyphens."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.name)) && length(var.name) >= 3 && length(var.name) <= 63 && !can(regex("--", var.name))
    error_message = "Container name must be between 3 and 63 characters, contain only lowercase letters, numbers, and hyphens, start and end with an alphanumeric character, and not contain consecutive hyphens."
  }
}

variable "storage_account_id" {
  description = "The Resource ID or name of the Storage Account in which the Container should be created. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = length(trimspace(var.storage_account_id)) > 0
    error_message = "storage_account_id must not be empty."
  }
}

variable "container_access_type" {
  description = "The Access Level configured for this Container. Possible values are 'blob', 'container', or 'private'. Defaults to 'private'."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["private", "blob", "container"], var.container_access_type)
    error_message = "container_access_type must be one of 'private', 'blob', or 'container'."
  }
}

variable "default_encryption_scope" {
  description = "The default encryption scope to use for blobs uploaded to this container. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "encryption_scope_override_enabled" {
  description = "Whether blob-level encryption scope overrides are enabled for blobs in this container. Defaults to false."
  type        = bool
  default     = false
}

variable "metadata" {
  description = "A mapping of custom name, value pairs for this container."
  type        = map(string)
  default     = {}
}

variable "blobs" {
  description = "List of storage blobs to provision inside this container."
  type = list(object({
    name           = string
    type           = optional(string, "Block")
    size           = optional(number, null)
    content_type   = optional(string, "application/octet-stream")
    source_content = optional(string, null)
    source_file    = optional(string, null)
    source_uri     = optional(string, null)
    access_tier    = optional(string, null)
    cache_control  = optional(string, null)
    content_md5    = optional(string, null)
    metadata       = optional(map(string), {})
  }))
  default = []
}
