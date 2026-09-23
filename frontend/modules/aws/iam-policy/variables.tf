variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "iam_policy" {
  description = "Map of AWS IAM Policy configurations to deploy, keyed by policy name."
  type = map(object({
    name                              = optional(string, "iam-policy-default")
    name_prefix                       = optional(string, null)
    description                       = optional(string, "Managed by Terraform")
    path                              = optional(string, "/")
    policy                            = optional(string, "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Sid\": \"DefaultCloudWatchLogsAccess\",\n      \"Effect\": \"Allow\",\n      \"Action\": [\n        \"logs:CreateLogGroup\",\n        \"logs:CreateLogStream\",\n        \"logs:PutLogEvents\"\n      ],\n      \"Resource\": \"*\"\n    }\n  ]\n}")
    delay_after_policy_creation_in_ms = optional(number, null)
    tags                              = optional(map(string), {})
  }))
  default = {
    "iam-policy-default" = {
      name                              = "iam-policy-default"
      name_prefix                       = null
      description                       = "Managed by Terraform"
      path                              = "/"
      policy                            = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Sid\": \"DefaultCloudWatchLogsAccess\",\n      \"Effect\": \"Allow\",\n      \"Action\": [\n        \"logs:CreateLogGroup\",\n        \"logs:CreateLogStream\",\n        \"logs:PutLogEvents\"\n      ],\n      \"Resource\": \"*\"\n    }\n  ]\n}"
      delay_after_policy_creation_in_ms = null
      tags                              = {}
    }
  }
}
