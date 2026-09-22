variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "iam_role" {
  description = "Map of AWS IAM Role configurations to deploy, keyed by role name."
  type = map(object({
    name                  = optional(string, "iam-role-default")
    name_prefix           = optional(string, null)
    assume_role_policy    = optional(string, "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Action\": \"sts:AssumeRole\",\n      \"Effect\": \"Allow\",\n      \"Principal\": {\n        \"Service\": \"ec2.amazonaws.com\"\n      }\n    }\n  ]\n}")
    description           = optional(string, "Managed by Terraform")
    path                  = optional(string, "/")
    force_detach_policies = optional(bool, false)
    max_session_duration  = optional(number, 3600)
    permissions_boundary  = optional(string, null)
    managed_policy_arns   = optional(list(string), [])
    inline_policy = optional(list(object({
      name   = string
      policy = string
    })), [])
    tags = optional(map(string), {})
  }))
  default = {
    "iam-role-default" = {
      name                  = "iam-role-default"
      name_prefix           = null
      assume_role_policy    = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Action\": \"sts:AssumeRole\",\n      \"Effect\": \"Allow\",\n      \"Principal\": {\n        \"Service\": \"ec2.amazonaws.com\"\n      }\n    }\n  ]\n}"
      description           = "Managed by Terraform"
      path                  = "/"
      force_detach_policies = false
      max_session_duration  = 3600
      permissions_boundary  = null
      managed_policy_arns   = []
      inline_policy         = []
      tags                  = {}
    }
  }
}
