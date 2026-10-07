variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "lt" {
  description = "Map of AWS Launch Template configurations to deploy, keyed by launch template name."
  type = map(object({
    name                        = optional(string, "lt-default")
    name_prefix                 = optional(string, null)
    description                 = optional(string, null)
    image_id                    = optional(string, null)
    instance_type               = optional(string, "t3.micro")
    key_name                    = optional(string, null)
    user_data                   = optional(string, null)
    ebs_optimized               = optional(bool, null)
    vpc_security_group_ids      = optional(list(string), null)
    update_default_version      = optional(bool, true)
    iam_instance_profile_name   = optional(string, null)
    iam_instance_profile_arn    = optional(string, null)
    enable_monitoring           = optional(bool, null)
    enable_metadata_options     = optional(bool, true)
    http_endpoint               = optional(string, "enabled")
    http_tokens                 = optional(string, "required")
    http_put_response_hop_limit = optional(number, 1)
    instance_metadata_tags      = optional(string, null)
    block_device_mappings = optional(list(object({
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
    })), [])
    network_interfaces = optional(list(object({
      associate_public_ip_address = optional(bool, null)
      delete_on_termination       = optional(bool, true)
      description                 = optional(string, null)
      device_index                = optional(number, 0)
      security_groups             = optional(list(string), null)
      subnet_id                   = optional(string, null)
    })), [])
    tag_specifications = optional(list(object({
      resource_type = string
      tags          = map(string)
    })), [])
    tags = optional(map(string), {})
  }))
  default = {
    "lt-default" = {
      name                        = "lt-default"
      name_prefix                 = null
      description                 = null
      image_id                    = null
      instance_type               = "t3.micro"
      key_name                    = null
      user_data                   = null
      ebs_optimized               = null
      vpc_security_group_ids      = null
      update_default_version      = true
      iam_instance_profile_name   = null
      iam_instance_profile_arn    = null
      enable_monitoring           = null
      enable_metadata_options     = true
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = 1
      instance_metadata_tags      = null
      block_device_mappings       = []
      network_interfaces          = []
      tag_specifications          = []
      tags                        = {}
    }
  }
}
