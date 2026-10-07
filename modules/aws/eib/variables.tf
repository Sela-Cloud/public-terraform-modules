variable "name" {
  description = "Base name to be used on all Image Builder resources."
  type        = string
  default     = "eib-default"
}

variable "description" {
  description = "Description for Image Builder resources."
  type        = string
  default     = null
}

variable "parent_image" {
  description = "The parent image AMI ID or base image ARN (e.g. 'arn:aws:imagebuilder:us-east-1:aws:image/amazon-linux-2-x86/x.x.x')."
  type        = string
  default     = "arn:aws:imagebuilder:us-east-1:aws:image/amazon-linux-2-x86/x.x.x"
}

variable "recipe_version" {
  description = "Version of the image recipe."
  type        = string
  default     = "1.0.0"
}

variable "components" {
  description = "List of Image Builder component ARNs to include in the recipe."
  type        = list(string)
  default     = []
}

variable "instance_types" {
  description = "List of EC2 instance types for the build instance."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "instance_profile_name" {
  description = "IAM instance profile name associated with the build instance. Required by AWS."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID for the build instance."
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "List of security group IDs for the build instance."
  type        = list(string)
  default     = []
}

variable "key_pair" {
  description = "Key pair name for the build instance."
  type        = string
  default     = null
}

variable "terminate_instance_on_failure" {
  description = "Whether to terminate build instance on failure."
  type        = bool
  default     = true
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for build notifications."
  type        = string
  default     = null
}

variable "schedule_expression" {
  description = "Cron or rate expression for the pipeline schedule (e.g. 'cron(0 0 ? * SUN *)')."
  type        = string
  default     = null
}

variable "pipeline_status" {
  description = "Status of the image pipeline ('ENABLED' or 'DISABLED')."
  type        = string
  default     = "ENABLED"

  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.pipeline_status)
    error_message = "The pipeline_status must be either 'ENABLED' or 'DISABLED'."
  }
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "block_device_mappings" {
  description = "Customize block device mappings (e.g. root volume size) for the resulting AMI."
  type = list(object({
    device_name = string
    ebs = optional(object({
      volume_size           = optional(number, null)
      volume_type           = optional(string, null)
      delete_on_termination = optional(bool, true)
      encrypted             = optional(bool, null)
      kms_key_id            = optional(string, null)
    }), null)
  }))
  default = []
}

variable "http_tokens" {
  description = "Whether IMDSv2 session tokens are required for build instances. Valid values: 'optional', 'required'. Null leaves instance_metadata_options unconfigured."
  type        = string
  default     = null
}

variable "http_put_response_hop_limit" {
  description = "HTTP PUT response hop limit for build instance metadata requests (1-64). Only used when http_tokens is set."
  type        = number
  default     = null
}

variable "logging_s3_bucket_name" {
  description = "S3 bucket name to store build logs. Null skips logging configuration."
  type        = string
  default     = null
}

variable "logging_s3_key_prefix" {
  description = "S3 key prefix for build logs. Only used when logging_s3_bucket_name is set."
  type        = string
  default     = null
}

variable "distributions" {
  description = "Per-region AMI distribution settings. When non-empty, creates a distribution configuration and attaches it to the pipeline."
  type = list(object({
    region                        = string
    ami_name                      = optional(string, null)
    ami_description               = optional(string, null)
    ami_tags                      = optional(map(string), {})
    kms_key_id                    = optional(string, null)
    launch_permission_account_ids = optional(list(string), [])
  }))
  default = []
}
