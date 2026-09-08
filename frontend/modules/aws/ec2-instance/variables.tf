variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "ec2_instance" {
  description = "Map of EC2 instance configurations to deploy, keyed by instance name."
  type = map(object({
    name                                 = optional(string, "ec2-instance")
    ami                                  = optional(string, null)
    instance_type                        = optional(string, "t3.micro")
    key_name                             = optional(string, null)
    subnet_id                            = optional(string, null)
    vpc_security_group_ids               = optional(list(string), [])
    associate_public_ip_address          = optional(bool, false)
    private_ip                           = optional(string, null)
    secondary_private_ips                = optional(list(string), [])
    source_dest_check                    = optional(bool, true)
    availability_zone                    = optional(string, null)
    placement_group                      = optional(string, null)
    tenancy                              = optional(string, "default")
    host_id                              = optional(string, null)
    cpu_core_count                       = optional(number, null)
    threads_per_core                     = optional(number, null)
    disable_api_termination              = optional(bool, false)
    disable_api_stop                     = optional(bool, false)
    instance_initiated_shutdown_behavior = optional(string, "stop")
    iam_instance_profile                 = optional(string, null)
    monitoring                           = optional(bool, false)
    ebs_optimized                        = optional(bool, true)
    cpu_credits                          = optional(string, "standard")
    auto_recovery                        = optional(string, "default")
    user_data                            = optional(string, null)
    user_data_base64                     = optional(string, null)
    user_data_replace_on_change          = optional(bool, false)
    enable_eip                           = optional(bool, false)
    eip_tags                             = optional(map(string), {})
    root_block_device = optional(object({
      volume_type           = optional(string, "gp3")
      volume_size           = optional(number, 30)
      delete_on_termination = optional(bool, true)
      encrypted             = optional(bool, true)
      kms_key_id            = optional(string, null)
      iops                  = optional(number, null)
      throughput            = optional(number, null)
      tags                  = optional(map(string), {})
      }), {
      volume_type           = "gp3"
      volume_size           = 30
      delete_on_termination = true
      encrypted             = true
    })
    ebs_block_device = optional(list(object({
      device_name           = string
      volume_type           = optional(string, "gp3")
      volume_size           = optional(number, 20)
      delete_on_termination = optional(bool, true)
      encrypted             = optional(bool, true)
      kms_key_id            = optional(string, null)
      iops                  = optional(number, null)
      throughput            = optional(number, null)
      snapshot_id           = optional(string, null)
      tags                  = optional(map(string), {})
    })), [])
    metadata_options = optional(object({
      http_endpoint               = optional(string, "enabled")
      http_tokens                 = optional(string, "required")
      http_put_response_hop_limit = optional(number, 2)
      http_protocol_ipv6          = optional(string, "disabled")
      instance_metadata_tags      = optional(string, "disabled")
      }), {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = 2
      http_protocol_ipv6          = "disabled"
      instance_metadata_tags      = "disabled"
    })
    tags        = optional(map(string), {})
    volume_tags = optional(map(string), {})
  }))
  default = {
    "ec2-instance-example" = {
      name                        = "ec2-instance-example"
      ami                         = null
      instance_type               = "t3.micro"
      key_name                    = null
      subnet_id                   = null
      vpc_security_group_ids      = []
      associate_public_ip_address = false
      private_ip                  = null
      secondary_private_ips       = []
      source_dest_check           = true
      availability_zone           = null
      placement_group             = null
      tenancy                     = "default"
      host_id                     = null
      cpu_core_count              = null
      threads_per_core            = null
      disable_api_termination     = false
      disable_api_stop            = false
      iam_instance_profile        = null
      monitoring                  = false
      ebs_optimized               = true
      cpu_credits                 = "standard"
      auto_recovery               = "default"
      user_data                   = null
      enable_eip                  = false
      eip_tags                    = {}
      root_block_device = {
        volume_type           = "gp3"
        volume_size           = 30
        delete_on_termination = true
        encrypted             = true
      }
      ebs_block_device = []
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        http_protocol_ipv6          = "disabled"
        instance_metadata_tags      = "disabled"
      }
      tags        = {}
      volume_tags = {}
    }
  }
}
