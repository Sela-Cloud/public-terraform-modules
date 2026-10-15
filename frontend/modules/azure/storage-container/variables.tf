variable "storage_container" {
  description = "Map of Azure Storage Container configurations to create."
  type = map(object({
    name                              = string
    storage_account_id                = string
    container_access_type             = optional(string, "private")
    default_encryption_scope          = optional(string, null)
    encryption_scope_override_enabled = optional(bool, false)
    metadata                          = optional(map(string), {})
    blobs = optional(list(object({
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
    })), [])
  }))
  default = {}
}
