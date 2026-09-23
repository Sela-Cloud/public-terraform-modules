variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "iam_group" {
  description = "Map of AWS IAM Group configurations to deploy, keyed by group name."
  type = map(object({
    name                = optional(string, "iam-group-default")
    path                = optional(string, "/")
    managed_policy_arns = optional(list(string), [])
  }))
  default = {
    "iam-group-default" = {
      name                = "iam-group-default"
      path                = "/"
      managed_policy_arns = []
    }
  }
}
