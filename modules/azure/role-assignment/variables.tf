variable "scope" {
  description = "The scope at which the Role Assignment applies to, such as a Management Group ID, Subscription ID, Resource Group ID, or Resource ID. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = length(trimspace(var.scope)) > 0
    error_message = "The scope variable must not be empty."
  }
}

variable "role_definition_name" {
  description = "The name of a built-in Azure Role (e.g. 'Reader', 'Contributor', 'Owner', 'Storage Blob Data Contributor'). Changing this forces a new resource to be created. Either role_definition_name or role_definition_id must be set."
  type        = string
  default     = "Reader"
}

variable "role_definition_id" {
  description = "The Scoped-ID of the Role Definition (e.g. '/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/00000000-0000-0000-0000-000000000000'). Changing this forces a new resource to be created. Mutually exclusive with role_definition_name."
  type        = string
  default     = null
}

variable "principal_id" {
  description = "The ID of the Principal (User, Group, Service Principal, or Managed Identity Object ID) to assign the Role Definition to. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.principal_id))
    error_message = "principal_id must be a valid Azure Active Directory / Entra ID Object ID (GUID format)."
  }
}

variable "name" {
  description = "A unique UUID/GUID for this Role Assignment. Changing this forces a new resource to be created. If not specified or not a valid UUID, Azure/Terraform generates one automatically."
  type        = string
  default     = null
}

variable "principal_type" {
  description = "The type of the principal_id. Possible values are 'User', 'Group', and 'ServicePrincipal'. Changing this forces a new resource to be created."
  type        = string
  default     = null

  validation {
    condition     = var.principal_type == null ? true : contains(["User", "Group", "ServicePrincipal"], var.principal_type)
    error_message = "principal_type must be either 'User', 'Group', or 'ServicePrincipal'."
  }
}

variable "description" {
  description = "The description for this Role Assignment."
  type        = string
  default     = null
}

variable "skip_service_principal_aad_check" {
  description = "If the principal_id is a newly provisioned Service Principal, set this value to true to skip the Azure Active Directory check which may fail due to replication lag. Defaults to false."
  type        = bool
  default     = false
}

variable "condition" {
  description = "The condition that limits the resources that the role can be assigned to (Attribute-Based Access Control / ABAC)."
  type        = string
  default     = null
}

variable "condition_version" {
  description = "The version of the condition. Possible values are '1.0' or '2.0'."
  type        = string
  default     = null

  validation {
    condition     = var.condition_version == null ? true : contains(["1.0", "2.0"], var.condition_version)
    error_message = "condition_version must be either '1.0' or '2.0'."
  }
}

variable "delegated_managed_identity_resource_id" {
  description = "The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. Used for cross-tenant scenarios."
  type        = string
  default     = null
}
