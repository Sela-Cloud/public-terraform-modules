variable "name" {
  description = "Friendly name of the policy. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix."
  type        = string
  default     = "iam-policy-default"

  validation {
    condition     = var.name == null || can(regex("^[a-zA-Z0-9+=,.@_-]{1,128}$", var.name))
    error_message = "The policy name must be between 1 and 128 characters and consist of alphanumeric characters and/or the symbols: +=,.@_-"
  }
}

variable "name_prefix" {
  description = "Creates a unique name beginning with the specified prefix. Conflicts with name."
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the IAM policy."
  type        = string
  default     = "Managed by Terraform"
}

variable "path" {
  description = "Path in which to create the policy. Must begin and end with a forward slash (/)."
  type        = string
  default     = "/"

  validation {
    condition     = can(regex("^(/|(/[a-zA-Z0-9_+=,.@-]+)+/)$", var.path))
    error_message = "The path must begin and end with a forward slash (/)."
  }
}

variable "policy" {
  description = "The policy document. This is a valid JSON formatted string."
  type        = string
  default     = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Sid\": \"DefaultCloudWatchLogsAccess\",\n      \"Effect\": \"Allow\",\n      \"Action\": [\n        \"logs:CreateLogGroup\",\n        \"logs:CreateLogStream\",\n        \"logs:PutLogEvents\"\n      ],\n      \"Resource\": \"*\"\n    }\n  ]\n}"

  validation {
    condition     = can(jsondecode(var.policy))
    error_message = "The policy must be a valid JSON formatted string."
  }
}

variable "delay_after_policy_creation_in_ms" {
  description = "Number of milliseconds to wait between creating the policy and setting its version as the default."
  type        = number
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the policy."
  type        = map(string)
  default     = {}
}
