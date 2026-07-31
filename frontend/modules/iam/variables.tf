variable "project_id" {
  description = "Google Cloud project ID in which custom roles, service accounts, and project-level IAM bindings are managed."
  type        = string
  default     = "sela"
}

variable "iam_configs" {
  description = "Map of IAM configurations keyed by a stable identifier. Each entry can create or reference one service account, grant project roles to one principal, create a custom role, and/or add IAM members directly to a service account."
  type = map(object({
    # New service account account ID. Mutually exclusive with existing_service_account_email.
    service_account_name = optional(string, "")
    # Project-level roles to grant to the entry's service account or user principal.
    project_level_roles = optional(list(string), [])
    # User principal to receive project_level_roles. Do not set when using a service account principal.
    user_email_address = optional(string, null)

    # Custom role ID and permissions. No custom role is created when custom_role_id is null.
    custom_role_id          = optional(string, null)
    custom_role_permissions = optional(list(string), [])
    # IAM members to grant roles on the created or referenced service account.
    iam_members = optional(map(object({
      member = string
      role   = string
    })), {})
    # Existing service account email. Mutually exclusive with service_account_name.
    existing_service_account_email = optional(string, "")
  }))
  default = {}

  validation {
    condition = alltrue([
      for config in var.iam_configs :
      !(config.service_account_name != "" && config.existing_service_account_email != "")
    ])
    error_message = "Set either service_account_name or existing_service_account_email, not both."
  }

  validation {
    condition = alltrue([
      for config in var.iam_configs :
      length(config.project_level_roles) == 0 || (
        (config.service_account_name != "" || config.existing_service_account_email != "") !=
        (config.user_email_address != null)
      )
    ])
    error_message = "Each configuration with project_level_roles must specify exactly one principal: a service account or user_email_address."
  }
}
