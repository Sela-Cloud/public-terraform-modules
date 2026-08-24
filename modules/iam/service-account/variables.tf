
variable "service_account_name" {
  description = "Account ID for a service account to create. Leave empty when existing_service_account_email identifies an existing account."
  type        = string
  default     = ""
}

variable "project_id" {
  description = "Google Cloud project ID in which the service account is created."
  type        = string
}

variable "iam_members" {
  type = map(object({
    member = string
    role   = string
  }))
  description = "Map of IAM bindings to apply to the service account. Each key must be unique and each value supplies a principal member and IAM role."
  default     = {}
  nullable    = false
}

variable "existing_service_account_email" {
  description = "Email address of an existing service account to manage. Leave empty to create service_account_name instead."
  type        = string
  default     = ""

  # A readable failure for a typo. Without it the provider reports its raw regexp, which describes
  # the fully-qualified form the module builds internally and never the email the caller passed.
  validation {
    condition = (
      var.existing_service_account_email == "" ||
      can(regex("^[^@ ]+@[^@ ]+\\.gserviceaccount\\.com$", var.existing_service_account_email)) ||
      startswith(var.existing_service_account_email, "projects/")
    )
    error_message = "existing_service_account_email must be a service account email such as name@project.iam.gserviceaccount.com."
  }
}
