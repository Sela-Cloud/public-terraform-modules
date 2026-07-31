
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
}
