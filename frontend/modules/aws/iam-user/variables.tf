variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
}

variable "iam_user" {
  description = "Map of AWS IAM User configurations to deploy, keyed by username."
  type = map(object({
    name                 = string
    path                 = optional(string, "/")
    permissions_boundary = optional(string, null)
    groups               = optional(list(string), [])
    managed_policy_arns  = optional(list(string), [])
    tags                 = optional(map(string), {})
  }))
  default = {}
}
