variable "name" {
  description = "The user's name. Must consist of upper and lowercase alphanumeric characters with no spaces. You can also include any of the following characters: =,.@-."
  type        = string
  default     = "iam-user-default"

  validation {
    condition     = can(regex("^[a-zA-Z0-9+=,.@_-]{1,64}$", var.name))
    error_message = "The user name must be between 1 and 64 characters and consist of alphanumeric characters and/or the symbols: +=,.@_-"
  }
}

variable "path" {
  description = "Path in which to create the user. Must begin and end with a forward slash (/)."
  type        = string
  default     = "/"

  validation {
    condition     = can(regex("^(/|(/[a-zA-Z0-9_+=,.@-]+)+/)$", var.path))
    error_message = "The path must begin and end with a forward slash (/)."
  }
}

variable "permissions_boundary" {
  description = "The ARN of the policy that is used to set the permissions boundary for the user."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the user."
  type        = map(string)
  default     = {}
}
