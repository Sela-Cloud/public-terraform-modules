variable "project_id" {
  description = "GCP Project ID on which the IAM role is granted."
  type        = string
}

variable "iam_project_binding" {
  description = "Project-level IAM role grants configured through the Sela Deployer catalog. One map entry is exactly one role granted to exactly one principal, so a single grant can be revoked without touching any other. Create-only: these grants are never adopted from existing project IAM policy."
  type = map(object({
    binding_key           = string
    principal_type        = string
    service_account_email = optional(string)
    user_email_address    = optional(string)
    principal_set_address = optional(string)
    role                  = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for binding in values(var.iam_project_binding) :
      contains(["serviceAccount", "user", "principalSet"], binding.principal_type)
    ])
    error_message = "Principal type must be serviceAccount, user or principalSet."
  }

  validation {
    condition = alltrue([
      for binding in values(var.iam_project_binding) :
      binding.principal_type != "serviceAccount" || try(trimspace(binding.service_account_email), "") != ""
    ])
    error_message = "A serviceAccount binding requires service_account_email."
  }

  validation {
    condition = alltrue([
      for binding in values(var.iam_project_binding) :
      binding.principal_type != "user" || try(trimspace(binding.user_email_address), "") != ""
    ])
    error_message = "A user binding requires user_email_address."
  }

  validation {
    condition = alltrue([
      for binding in values(var.iam_project_binding) :
      binding.principal_type != "principalSet" || try(trimspace(binding.principal_set_address), "") != ""
    ])
    error_message = "A principalSet binding requires principal_set_address."
  }

  validation {
    condition = alltrue([
      for binding in values(var.iam_project_binding) :
      startswith(binding.role, "roles/") || startswith(binding.role, "projects/") || startswith(binding.role, "organizations/")
    ])
    error_message = "Role must be a predefined role such as roles/viewer or a fully qualified custom role name."
  }
}
