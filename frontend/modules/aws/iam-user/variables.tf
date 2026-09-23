variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "iam_user" {
  description = "Map of AWS IAM User configurations to deploy, keyed by username."
  type = map(object({
    name                 = optional(string, "iam-user-default")
    path                 = optional(string, "/")
    permissions_boundary = optional(string, null)
    tags                 = optional(map(string), {})
  }))
  default = {
    "iam-user-default" = {
      name                 = "iam-user-default"
      path                 = "/"
      permissions_boundary = null
      tags                 = {}
    }
  }
}
