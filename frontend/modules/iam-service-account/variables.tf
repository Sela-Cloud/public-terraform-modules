variable "project_id" {
  description = "GCP Project ID in which the service account is created."
  type        = string
}

variable "iam_service_account" {
  description = "Service accounts configured through the Sela Deployer catalog. One map entry is exactly one service account, so it can be deleted without touching custom roles or project-level IAM bindings. Project-level role grants are requested through the iam-project-binding module."
  type = map(object({
    service_account_name = string
    iam_members = optional(map(object({
      member = string
      role   = string
    })), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for service_account in values(var.iam_service_account) :
      can(regex("^[a-z]([-a-z0-9]{4,28}[a-z0-9])$", service_account.service_account_name))
    ])
    error_message = "Service account IDs must be 6-30 characters, start with a lowercase letter, and contain only lowercase letters, numbers and hyphens."
  }
}
