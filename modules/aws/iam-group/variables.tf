variable "name" {
  description = "The group's name. Must consist of upper and lowercase alphanumeric characters with no spaces. You can also include any of the following characters: =,.@-."
  type        = string
  default     = "iam-group-default"

  validation {
    condition     = can(regex("^[a-zA-Z0-9+=,.@_-]{1,128}$", var.name))
    error_message = "The group name must be between 1 and 128 characters and consist of alphanumeric characters and/or the symbols: +=,.@_-"
  }
}

variable "path" {
  description = "Path in which to create the group. Must begin and end with a forward slash (/)."
  type        = string
  default     = "/"

  validation {
    condition     = can(regex("^(/|(/[a-zA-Z0-9_+=,.@-]+)+/)$", var.path))
    error_message = "The path must begin and end with a forward slash (/)."
  }
}

variable "managed_policy_arns" {
  description = "List of IAM policy ARNs to attach to the IAM group."
  type        = list(string)
  default     = []
}
