variable "service_account_address" {
  description = "Service account email to receive project_roles. Mutually exclusive with user_email_address and principal_set_address."
  type        = string
  default     = null
}
variable "user_email_address" {
  description = "User email address to receive project_roles. Mutually exclusive with service_account_address and principal_set_address."
  type        = string
  default     = null
}
variable "principal_set_address" {
  description = "Principal set address (for example, allUsers or allAuthenticatedUsers) to receive project_roles. Mutually exclusive with service_account_address and user_email_address."
  type        = string
  default     = null
}
variable "project" {
  description = "Google Cloud project ID in which to grant project_roles."
  type        = string
  default     = null
}
variable "project_roles" {
  description = "IAM roles to grant to the selected principal at the project level."
  type        = list(string)
  default     = []
}
