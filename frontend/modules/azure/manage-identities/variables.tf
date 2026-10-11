variable "manage_identities" {
  description = "Map of Azure Managed Identity configurations to create."

  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    tags                = optional(map(string), {})
    role_assignments = optional(list(object({
      scope                            = string
      role_definition_name             = optional(string, null)
      role_definition_id               = optional(string, null)
      description                      = optional(string, null)
      skip_service_principal_aad_check = optional(bool, true)
    })), [])
  }))
  default = {}
}
