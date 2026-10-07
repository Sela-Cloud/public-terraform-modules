variable "name" {
  description = "The name of the launch template. Set at most one of name/name_prefix."
  type        = string
  default     = null
}

variable "name_prefix" {
  description = "Creates a unique name beginning with the specified prefix. Conflicts with name."
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the launch template."
  type        = string
  default     = null
}

variable "image_id" {
  description = "The AMI ID to use to launch the instance."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "The instance type to use for the instance."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "The key name to use for the instance."
  type        = string
  default     = null
}

variable "user_data" {
  description = "The base64-encoded or plain-text user data script for the instance."
  type        = string
  default     = null
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized."
  type        = bool
  default     = null
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with the instance."
  type        = list(string)
  default     = null
}

variable "update_default_version" {
  description = "Whether to update Default Version each update."
  type        = bool
  default     = true
}

variable "iam_instance_profile_name" {
  description = "The name of the IAM instance profile to associate with the instance."
  type        = string
  default     = null
}

variable "iam_instance_profile_arn" {
  description = "The ARN of the IAM instance profile to associate with the instance."
  type        = string
  default     = null
}

variable "enable_monitoring" {
  description = "Whether to enable detailed CloudWatch monitoring for the instance."
  type        = bool
  default     = null
}

variable "enable_metadata_options" {
  description = "Whether to configure instance metadata options (IMDS)."
  type        = bool
  default     = true
}

variable "http_endpoint" {
  description = "Whether the metadata service is available. Valid values: 'enabled', 'disabled'."
  type        = string
  default     = "enabled"
}

variable "http_tokens" {
  description = "Whether to require IMDSv2 tokens. Valid values: 'optional', 'required'."
  type        = string
  default     = "required"
}

variable "http_put_response_hop_limit" {
  description = "The desired HTTP PUT response hop limit for instance metadata requests."
  type        = number
  default     = 1
}

variable "instance_metadata_tags" {
  description = "Enables or disables access to instance tags from the instance metadata. Valid values: 'enabled', 'disabled'."
  type        = string
  default     = null
}

variable "block_device_mappings" {
  description = "Specify EBS volume configurations to attach to the instance."
  type = list(object({
    device_name = string
    ebs = optional(object({
      volume_size           = optional(number, 20)
      volume_type           = optional(string, "gp3")
      iops                  = optional(number, null)
      throughput            = optional(number, null)
      encrypted             = optional(bool, true)
      kms_key_id            = optional(string, null)
      delete_on_termination = optional(bool, true)
      snapshot_id           = optional(string, null)
    }), null)
  }))
  default = []
}

variable "network_interfaces" {
  description = "Customize network interfaces to be attached at instance boot."
  type = list(object({
    associate_public_ip_address = optional(bool, null)
    delete_on_termination       = optional(bool, true)
    description                 = optional(string, null)
    device_index                = optional(number, 0)
    security_groups             = optional(list(string), null)
    subnet_id                   = optional(string, null)
  }))
  default = []
}

variable "tag_specifications" {
  description = "The tags to apply to resources (instance, volume, etc.) during launch."
  type = list(object({
    resource_type = string
    tags          = map(string)
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to assign to the launch template."
  type        = map(string)
  default     = {}
}

variable "disable_api_termination" {
  description = "If true, enables EC2 instance termination protection."
  type        = bool
  default     = null
}

variable "disable_api_stop" {
  description = "If true, enables EC2 instance stop protection."
  type        = bool
  default     = null
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance. Valid values: 'stop', 'terminate'."
  type        = string
  default     = null
}

variable "placement" {
  description = "Placement of the instance: availability zone, tenancy, host, or placement group."
  type = object({
    availability_zone = optional(string, null)
    affinity          = optional(string, null)
    group_name        = optional(string, null)
    host_id           = optional(string, null)
    tenancy           = optional(string, null)
  })
  default = null
}

variable "cpu_options" {
  description = "CPU options for the instance (core count, threads per core)."
  type = object({
    core_count       = optional(number, null)
    threads_per_core = optional(number, null)
  })
  default = null
}

variable "credit_specification" {
  description = "Credit option for CPU usage on burstable (T-family) instances. cpu_credits: 'standard' or 'unlimited'."
  type = object({
    cpu_credits = string
  })
  default = null
}

variable "instance_market_options" {
  description = "Purchasing option for the instance, e.g. Spot."
  type = object({
    market_type = optional(string, "spot")
    spot_options = optional(object({
      max_price                      = optional(string, null)
      spot_instance_type             = optional(string, "one-time")
      instance_interruption_behavior = optional(string, "terminate")
      valid_until                    = optional(string, null)
    }), null)
  })
  default = null
}
