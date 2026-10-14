variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
}

variable "iam_group" {
  description = "Map of AWS IAM Group configurations to deploy, keyed by group name."
  type = map(object({
    name                = string
    path                = optional(string, "/")
    managed_policy_arns = optional(list(string), [])
    users               = optional(list(string), [])
  }))
  default = {}
}
