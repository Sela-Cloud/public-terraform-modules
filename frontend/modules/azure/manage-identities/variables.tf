variable "manage_identities" {
  description = "Map of Azure Managed Identity configurations to create."
  type = map(object({
    name                = optional(string, "uai-default")
    resource_group_name = optional(string, "rg-default")
    location            = optional(string, "eastus")
    tags                = optional(map(string), {})
    role_assignments = optional(list(object({
      scope                = string
      role_definition_name = optional(string, null)
      role_definition_id   = optional(string, null)
      description          = optional(string, null)
    })), [])
  }))
  default = {}
}
