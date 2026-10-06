################################################################################
# General / Core Configuration
################################################################################

variable "name" {
  description = "The name of the Network Load Balancer. This name must be unique within your AWS account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen."
  type        = string
  default     = "network-load-balancer"

  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]{0,30}[a-zA-Z0-9])?$", var.name))
    error_message = "The name must be 1-32 characters, contain only alphanumeric characters and hyphens, and cannot start or end with a hyphen."
  }
}

variable "name_prefix" {
  description = "Creates a unique name beginning with the specified prefix. Conflicts with name. Maximum 6 characters."
  type        = string
  default     = null

  validation {
    condition     = var.name_prefix == null || can(regex("^[a-zA-Z0-9-]{1,6}$", var.name_prefix))
    error_message = "The name_prefix must be between 1 and 6 characters and contain only alphanumeric characters and hyphens."
  }
}

variable "internal" {
  description = "Whether the load balancer is internal or internet-facing. Default is false (internet-facing)."
  type        = bool
  default     = false
}

variable "ip_address_type" {
  description = "The type of IP addresses used by the subnets for your load balancer. The possible values are 'ipv4' and 'dualstack'."
  type        = string
  default     = "ipv4"

  validation {
    condition     = contains(["ipv4", "dualstack"], var.ip_address_type)
    error_message = "The ip_address_type must be either 'ipv4' or 'dualstack'."
  }
}

################################################################################
# Networking & Subnets
################################################################################

variable "vpc_id" {
  description = "VPC ID where the NLB, security group, and target groups reside."
  type        = string
  default     = null
}

variable "subnets" {
  description = "A list of at least two subnet IDs across different Availability Zones to attach to the NLB. Mutually exclusive with subnet_mapping."
  type        = list(string)
  default     = []
}

variable "subnet_mapping" {
  description = "A list of subnet mapping blocks for attaching subnets with specific Elastic IP allocation IDs or private IPs. Mutually exclusive with subnets."
  type = list(object({
    subnet_id            = string
    allocation_id        = optional(string, null)
    private_ipv4_address = optional(string, null)
    ipv6_address         = optional(string, null)
  }))
  default = []
}

################################################################################
# Security Groups (Supported by AWS NLB)
################################################################################

variable "security_groups" {
  description = "A list of existing Security Group IDs to assign to the NLB."
  type        = list(string)
  default     = []
}

variable "create_security_group" {
  description = "Whether to create a dedicated Security Group for the NLB."
  type        = bool
  default     = false
}

variable "security_group_name" {
  description = "Name for the dedicated Security Group. Defaults to '<name>-sg' if not specified."
  type        = string
  default     = null
}

variable "security_group_description" {
  description = "Description for the dedicated Security Group."
  type        = string
  default     = "Security group for Network Load Balancer"
}

variable "security_group_ingress_rules" {
  description = "List of ingress rules for the dedicated Security Group."
  type = list(object({
    description                  = optional(string, null)
    from_port                    = optional(number, null)
    to_port                      = optional(number, null)
    ip_protocol                  = optional(string, "tcp")
    cidr_ipv4                    = optional(string, null)
    cidr_ipv6                    = optional(string, null)
    referenced_security_group_id = optional(string, null)
  }))
  default = [
    {
      description = "Allow TCP inbound traffic"
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    },
    {
      description = "Allow TLS inbound traffic"
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]
}

variable "security_group_egress_rules" {
  description = "List of egress rules for the dedicated Security Group."
  type = list(object({
    description                  = optional(string, null)
    from_port                    = optional(number, null)
    to_port                      = optional(number, null)
    ip_protocol                  = optional(string, "-1")
    cidr_ipv4                    = optional(string, "0.0.0.0/0")
    cidr_ipv6                    = optional(string, null)
    referenced_security_group_id = optional(string, null)
  }))
  default = [
    {
      description = "Allow all outbound traffic"
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]
}

################################################################################
# NLB Attributes & Behavior
################################################################################

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API."
  type        = bool
  default     = false
}

variable "enable_cross_zone_load_balancing" {
  description = "Indicates whether cross-zone load balancing is enabled. Default is false for Network Load Balancers."
  type        = bool
  default     = false
}

variable "client_keep_alive" {
  description = "Client keep alive value in seconds. The valid range is 60-604800 seconds. The default is 3600 seconds."
  type        = number
  default     = 3600
}

variable "dns_record_client_routing_policy" {
  description = "Indicates how traffic is distributed among the load balancer Availability Zones. Possible values are 'any_availability_zone', 'availability_zone_affinity', or 'partial_availability_zone_affinity'."
  type        = string
  default     = null
}

variable "access_logs" {
  description = "Map containing access logging configuration for the NLB."
  type = object({
    bucket  = string
    prefix  = optional(string, null)
    enabled = optional(bool, true)
  })
  default = null
}

################################################################################
# Target Groups
################################################################################

variable "target_groups" {
  description = "Map of target group definitions to create for the NLB."
  type = map(object({
    name                   = optional(string, null)
    name_prefix            = optional(string, null)
    port                   = optional(number, 80)
    protocol               = optional(string, "TCP")
    target_type            = optional(string, "instance")
    vpc_id                 = optional(string, null)
    deregistration_delay   = optional(number, 300)
    preserve_client_ip     = optional(bool, true)
    proxy_protocol_v2      = optional(bool, false)
    connection_termination = optional(bool, false)
    health_check = optional(object({
      enabled             = optional(bool, true)
      protocol            = optional(string, "TCP")
      port                = optional(string, "traffic-port")
      path                = optional(string, null)
      interval            = optional(number, 10)
      timeout             = optional(number, 10)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
      matcher             = optional(string, null)
    }), {})
    stickiness = optional(object({
      enabled = optional(bool, false)
      type    = optional(string, "source_ip")
    }), {})
    tags = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# Target Group Attachments
################################################################################

variable "target_group_attachments" {
  description = "Map of target group attachments to register targets with target groups."
  type = map(object({
    target_group_key  = string
    target_id         = string
    port              = optional(number, null)
    availability_zone = optional(string, null)
  }))
  default = {}
}

################################################################################
# Listeners
################################################################################

variable "listeners" {
  description = "Map of listener configurations to create for the NLB."
  type = map(object({
    port             = number
    protocol         = optional(string, "TCP")
    ssl_policy       = optional(string, null)
    certificate_arn  = optional(string, null)
    alpn_policy      = optional(string, null)
    target_group_key = optional(string, null)
    target_group_arn = optional(string, null)
    forward = optional(object({
      target_groups = list(object({
        target_group_key = optional(string, null)
        target_group_arn = optional(string, null)
        weight           = optional(number, 1)
      }))
    }), null)
    tags = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# Extra Listener Certificates (SNI for TLS listeners)
################################################################################

variable "extra_certificates" {
  description = "Map of additional certificates to associate with TLS listeners (SNI support)."
  type = map(object({
    listener_key    = string
    certificate_arn = string
  }))
  default = {}
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "A map of tags to assign to all resources created by this module."
  type        = map(string)
  default     = {}
}
