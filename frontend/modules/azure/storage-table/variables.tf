variable "storage_table" {
  description = "Map of Azure Storage Table configurations to create."
  type = map(object({
    name               = string
    storage_account_id = string
    acl = optional(list(object({
      id = string
      access_policy = optional(object({
        permissions = string
        start       = optional(string, null)
        expiry      = optional(string, null)
      }), null)
    })), [])
    timeouts = optional(object({
      create = optional(string, null)
      read   = optional(string, null)
      update = optional(string, null)
      delete = optional(string, null)
    }), {})
  }))
  default = {}
}
