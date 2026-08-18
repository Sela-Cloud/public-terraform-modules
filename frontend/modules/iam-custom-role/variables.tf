variable "project_id" {
  description = "GCP Project ID in which the custom role is created."
  type        = string
}

variable "iam_custom_role" {
  description = "Project-level custom IAM roles configured through the Sela Deployer catalog. One map entry is exactly one custom role, so it can be deleted without touching service accounts or IAM bindings."
  type = map(object({
    role_id     = string
    permissions = list(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for role in values(var.iam_custom_role) :
      can(regex("^[a-zA-Z0-9_.]{3,64}$", role.role_id))
    ])
    error_message = "Custom role IDs must be 3-64 characters of letters, numbers, underscores or periods."
  }

  validation {
    condition = alltrue([
      for role in values(var.iam_custom_role) :
      length(role.permissions) > 0
    ])
    error_message = "A custom role must grant at least one permission."
  }
}
