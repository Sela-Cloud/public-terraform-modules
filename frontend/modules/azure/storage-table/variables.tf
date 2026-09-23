variable "storage_table" {
  description = "Map of Azure Storage Table configurations to create."
  type = map(object({
    name               = optional(string, "mysampletable")
    storage_account_id = optional(string, "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-default/providers/Microsoft.Storage/storageAccounts/storagedefault")
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
