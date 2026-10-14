variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
}

variable "ec2_instance" {
  description = "Map of EC2 instance configurations to deploy, keyed by instance name."
  type = map(object({
    name                                 = optional(string)
    ami                                  = optional(string, null)
    instance_type                        = optional(string, "t3.micro")
    key_name                             = optional(string, null)
    vpc_id                               = optional(string, null)
    subnet_id                            = optional(string, null)
    vpc_security_group_ids               = optional(list(string), [])
    associate_public_ip_address          = optional(bool, false)
    private_ip                           = optional(string, null)
    secondary_private_ips                = optional(list(string), [])
    source_dest_check                    = optional(bool, true)
    availability_zone                    = optional(string)
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
    tags                       = optional(map(string), {})
    volume_tags                = optional(map(string), {})
    create_key_pair            = optional(bool, false)
    key_pair_name              = optional(string, null)
    public_key                 = optional(string, null)
    generate_ssh_key           = optional(bool, false)
    ssh_user                   = optional(string, "ec2-user")
    create_security_group      = optional(bool, false)
    security_group_name        = optional(string, null)
    security_group_description = optional(string, "Security group for EC2 instance with SSH access")
    ssh_cidr_blocks            = optional(list(string), ["0.0.0.0/0"])
    security_group_tags        = optional(map(string), {})
    instance_market_options = optional(object({
      market_type = optional(string, "spot")
      spot_options = optional(object({
        max_price                      = optional(string, null)
        spot_instance_type             = optional(string, "one-time")
        instance_interruption_behavior = optional(string, "terminate")
        valid_until                    = optional(string, null)
      }), null)
    }), null)
    enable_enclave = optional(bool, null)
    private_dns_name_options = optional(object({
      hostname_type                        = optional(string, null)
      enable_resource_name_dns_a_record    = optional(bool, null)
      enable_resource_name_dns_aaaa_record = optional(bool, null)
    }), null)
    capacity_reservation_specification = optional(object({
      capacity_reservation_preference = optional(string, null)
      capacity_reservation_target = optional(object({
        capacity_reservation_id                 = optional(string, null)
        capacity_reservation_resource_group_arn = optional(string, null)
      }), null)
    }), null)
    ephemeral_block_device = optional(list(object({
      device_name  = string
      virtual_name = optional(string, null)
      no_device    = optional(bool, null)
    })), [])
  }))
  default = {}
}
