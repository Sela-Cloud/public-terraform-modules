
variable "project" {
  description = "Google Cloud project ID in which the custom role is created."
}

variable "role_id" {
  description = "Custom role ID, without the projects/{project}/roles/ prefix."
}

variable "permissions" {
  description = "List of IAM permissions granted by the custom role."
}
