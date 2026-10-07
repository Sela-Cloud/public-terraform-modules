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
  description = "IAM instance profile name associated with the build instance."
  type        = string
  default     = ""
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
