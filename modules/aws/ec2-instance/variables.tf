################################################################################
# General / Core Configuration
################################################################################

variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "ap-south-1"
}

variable "name" {
  description = "Name to be used on all resources as identifier, applied as the 'Name' tag."
  type        = string
  default     = "ec2-instance"
}

variable "ami" {
  description = "The AMI to use for the instance. If null, the latest Amazon Linux 2023 AMI is used."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "The instance type of the EC2 instance."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "The key name of the Key Pair to use for the instance."
  type        = string
  default     = null
}

variable "availability_zone" {
  description = "AZ where the instance should be created. If null, AWS assigns an AZ automatically."
  type        = string
  default     = null
}

variable "placement_group" {
  description = "The placement group to start the instance in."
  type        = string
  default     = null
}

variable "tenancy" {
  description = "The tenancy of the instance (default, dedicated, or host)."
  type        = string
  default     = "default"
}

variable "host_id" {
  description = "ID of a dedicated host the instance will be assigned to (only applies when tenancy is 'host')."
  type        = string
  default     = null
}

variable "cpu_core_count" {
  description = "Sets the number of CPU cores for an instance."
  type        = number
  default     = null
}

variable "threads_per_core" {
  description = "Sets the number of threads per CPU core (e.g. 1 to disable Hyper-Threading)."
  type        = number
  default     = null
}

################################################################################
# Networking & Interfaces
################################################################################

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in."
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with."
  type        = list(string)
  default     = []
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with an instance in a VPC."
  type        = bool
  default     = false
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC."
  type        = string
  default     = null
}

variable "secondary_private_ips" {
  description = "A list of secondary private IPv4 addresses to assign to the instance's primary network interface."
  type        = list(string)
  default     = []
}

variable "source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPN instances."
  type        = bool
  default     = true
}

variable "enable_eip" {
  description = "Whether to allocate and associate an Elastic IP (EIP) to this EC2 instance."
  type        = bool
  default     = false
}

variable "eip_tags" {
  description = "A map of tags to assign to the Elastic IP resource if enabled."
  type        = map(string)
  default     = {}
}

################################################################################
# Storage (Root and Additional Disks)
################################################################################

variable "root_block_device" {
  description = "Configuration block for the root block device of the instance."
  type = object({
    volume_type           = optional(string, "gp3")
    volume_size           = optional(number, 30)
    delete_on_termination = optional(bool, true)
    encrypted             = optional(bool, true)
    kms_key_id            = optional(string, null)
    iops                  = optional(number, null)
    throughput            = optional(number, null)
    tags                  = optional(map(string), {})
  })
  default = {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = true
  }
}

variable "ebs_block_device" {
  description = "Additional EBS volume attachments to create and mount on the instance."
  type = list(object({
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
  }))
  default = []
}

################################################################################
# Security & IAM
################################################################################

variable "iam_instance_profile" {
  description = "The IAM Instance Profile name or ARN to launch the instance with."
  type        = string
  default     = null
}

variable "metadata_options" {
  description = "Customize the metadata options of the instance (IMDSv2 settings)."
  type = object({
    http_endpoint               = optional(string, "enabled")
    http_tokens                 = optional(string, "required")
    http_put_response_hop_limit = optional(number, 2)
    http_protocol_ipv6          = optional(string, "disabled")
    instance_metadata_tags      = optional(string, "disabled")
  })
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    http_protocol_ipv6          = "disabled"
    instance_metadata_tags      = "disabled"
  }
}

################################################################################
# Protection, Maintenance & Monitoring
################################################################################

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection."
  type        = bool
  default     = false
}

variable "disable_api_stop" {
  description = "If true, enables EC2 Instance Stop Protection."
  type        = bool
  default     = false
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance. Accepted values: 'stop' or 'terminate'."
  type        = string
  default     = "stop"
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled."
  type        = bool
  default     = false
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized."
  type        = bool
  default     = true
}

variable "cpu_credits" {
  description = "Credit specification for T2/T3/T4g instances ('standard' or 'unlimited')."
  type        = string
  default     = "standard"
}

variable "auto_recovery" {
  description = "Automatic recovery behavior of the instance ('default' or 'disabled')."
  type        = string
  default     = "default"
}

################################################################################
# User Data & Bootstrapping
################################################################################

variable "user_data" {
  description = "The user-data script to provide when launching the instance."
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Can be used instead of user_data to pass base64-encoded binary data directly."
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "When used in combination with user_data or user_data_base64 will trigger a destroy and recreate when set to true."
  type        = bool
  default     = false
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "A mapping of tags to assign to the instance and related resources."
  type        = map(string)
  default     = {}
}

variable "volume_tags" {
  description = "A mapping of tags to assign to all EBS volumes created directly with the instance."
  type        = map(string)
  default     = {}
}
