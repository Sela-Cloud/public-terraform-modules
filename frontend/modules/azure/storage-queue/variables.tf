variable "storage_queue" {
  description = "Map of Azure Storage Queue configurations to create."
  type = map(object({
    name               = string
    storage_account_id = string
    metadata           = optional(map(string), {})
    timeouts = optional(object({
      create = optional(string, null)
      read   = optional(string, null)
      update = optional(string, null)
      delete = optional(string, null)
    }), {})
  }))
  default = {}
}
