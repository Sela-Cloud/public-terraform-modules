variable "role_assignment" {
  description = "Map of Azure Role Assignment (RBAC) configurations to create."
  type = map(object({
    name                                   = optional(string, null)
    scope                                  = string
    role_definition_name                   = optional(string, "Reader")
    role_definition_id                     = optional(string, null)
    principal_id                           = string
    principal_type                         = optional(string, null)
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
  }))
  default = {}
}
