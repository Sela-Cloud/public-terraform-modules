variable "file_share" {
  description = "Map of Azure Storage File Share configurations to create."
  type = map(object({
    name               = string
    storage_account_id = string
    quota              = optional(number, 50)
    access_tier        = optional(string, null)
    enabled_protocol   = optional(string, "SMB")
    metadata           = optional(map(string), {})
    acl = optional(list(object({
      id = string
      access_policy = optional(object({
        permissions = string
        start       = optional(string, null)
        expiry      = optional(string, null)
      }), null)
    })), [])
  }))
  default = {}
}
