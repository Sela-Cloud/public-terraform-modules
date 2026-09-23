variable "name" {
  description = "Friendly name of the role. If omitted, Terraform will assign a random, unique name."
  type        = string
  default     = "iam-role-default"
}

variable "name_prefix" {
  description = "Creates a unique friendly name beginning with the specified prefix. Conflicts with name."
  type        = string
  default     = null
}

variable "assume_role_policy" {
  description = "Policy that grants an entity permission to assume the role. Must be a valid JSON formatted string."
  type        = string
  default     = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Action\": \"sts:AssumeRole\",\n      \"Effect\": \"Allow\",\n      \"Principal\": {\n        \"Service\": \"ec2.amazonaws.com\"\n      }\n    }\n  ]\n}"
}

variable "description" {
  description = "Description of the role."
  type        = string
  default     = "Managed by Terraform"
}

variable "path" {
  description = "Path to the role. Must begin and end with a forward slash (/)."
  type        = string
  default     = "/"

  validation {
    condition     = can(regex("^(/|(/[a-zA-Z0-9_+=,.@-]+)+/)$", var.path))
    error_message = "The path must begin and end with a forward slash (/)."
  }
}

variable "force_detach_policies" {
  description = "Whether to force detaching any policies the role has before destroying it."
  type        = bool
  default     = false
}

variable "max_session_duration" {
  description = "Maximum session duration (in seconds) that you want to set for the specified role. Valid values between 3600 (1 hour) and 43200 (12 hours)."
  type        = number
  default     = 3600

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "The max_session_duration must be between 3600 seconds (1 hour) and 43200 seconds (12 hours)."
  }
}

variable "permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the role."
  type        = string
  default     = null
}

variable "managed_policy_arns" {
  description = "List of exclusive IAM managed policy ARNs to attach to the IAM role."
  type        = list(string)
  default     = []
}

variable "inline_policy" {
  description = "Configuration block defining exclusive IAM inline policies associated with the IAM role."
  type = list(object({
    name   = string
    policy = string
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to assign to the role."
  type        = map(string)
  default     = {}
}
