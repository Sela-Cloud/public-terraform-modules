################################################################################
# General / Core Configuration
################################################################################

variable "name" {
  description = "The name of the Application Load Balancer. This name must be unique within your AWS account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen."
  type        = string
  default     = "app-load-balancer"

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
  description = "VPC ID where the ALB, security group, and target groups reside."
  type        = string
  default     = null
}

variable "subnets" {
  description = "A list of at least two subnet IDs across different Availability Zones to attach to the ALB. Mutually exclusive with subnet_mapping."
  type        = list(string)
  default     = []
}

variable "subnet_mapping" {
  description = "A list of subnet mapping blocks for attaching subnets with specific EIP allocation IDs or private IPs. Mutually exclusive with subnets."
  type = list(object({
    subnet_id            = string
    allocation_id        = optional(string, null)
    private_ipv4_address = optional(string, null)
    ipv6_address         = optional(string, null)
  }))
  default = []
}

################################################################################
# Security Groups
################################################################################

variable "security_groups" {
  description = "A list of existing Security Group IDs to assign to the ALB."
  type        = list(string)
  default     = []
}

variable "create_security_group" {
  description = "Whether to create a dedicated Security Group for the ALB."
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
  default     = "Security group for Application Load Balancer"
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
      description = "Allow HTTP inbound from all"
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    },
    {
      description = "Allow HTTPS inbound from all"
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
# ALB Attributes & Behavior
################################################################################

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle. Default is 60."
  type        = number
  default     = 60
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API."
  type        = bool
  default     = false
}

variable "enable_cross_zone_load_balancing" {
  description = "Indicates whether cross-zone load balancing is enabled. Default is true for Application Load Balancers."
  type        = bool
  default     = true
}

variable "enable_http2" {
  description = "Indicates whether HTTP/2 is enabled. Default is true."
  type        = bool
  default     = true
}

variable "enable_tls_version_and_cipher_suite_headers" {
  description = "Indicates whether the two headers (x-amzn-tls-version and x-amzn-tls-cipher-suite) are sent to the client. Default is false."
  type        = bool
  default     = false
}

variable "enable_waf_fail_open" {
  description = "Indicates whether to route requests to targets if WAF is unavailable. Default is false."
  type        = bool
  default     = false
}

variable "enable_xff_client_port" {
  description = "Indicates whether the X-Forwarded-For header should preserve the source port. Default is false."
  type        = bool
  default     = false
}

variable "drop_invalid_header_fields" {
  description = "Indicates whether HTTP headers with invalid header fields are removed by the load balancer (true) or routed to targets (false). Default is false."
  type        = bool
  default     = false
}

variable "preserve_host_header" {
  description = "Indicates whether the Application Load Balancer should preserve the Host header in the HTTP request and send it to the target without any change. Default is false."
  type        = bool
  default     = false
}

variable "client_keep_alive" {
  description = "Client keep alive value in seconds. The valid range is 60-604800 seconds. The default is 3600 seconds."
  type        = number
  default     = 3600
}

variable "access_logs" {
  description = "Map containing access logging configuration for the ALB."
  type = object({
    bucket  = string
    prefix  = optional(string, null)
    enabled = optional(bool, true)
  })
  default = null
}

variable "connection_logs" {
  description = "Map containing connection logging configuration for the ALB."
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
  description = "Map of target group definitions to create."
  type = map(object({
    name                          = optional(string, null)
    name_prefix                   = optional(string, null)
    port                          = optional(number, 80)
    protocol                      = optional(string, "HTTP")
    protocol_version              = optional(string, "HTTP1")
    target_type                   = optional(string, "instance")
    vpc_id                        = optional(string, null)
    deregistration_delay          = optional(number, 300)
    slow_start                    = optional(number, 0)
    load_balancing_algorithm_type = optional(string, "round_robin")
    health_check = optional(object({
      enabled             = optional(bool, true)
      path                = optional(string, "/")
      protocol            = optional(string, "HTTP")
      port                = optional(string, "traffic-port")
      interval            = optional(number, 30)
      timeout             = optional(number, 5)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
      matcher             = optional(string, "200-299")
    }), {})
    stickiness = optional(object({
      enabled         = optional(bool, false)
      type            = optional(string, "lb_cookie")
      cookie_duration = optional(number, 86400)
      cookie_name     = optional(string, null)
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
  description = "Map of listener configurations to create for the ALB."
  type = map(object({
    port                = number
    protocol            = optional(string, "HTTP")
    ssl_policy          = optional(string, null)
    certificate_arn     = optional(string, null)
    alpn_policy         = optional(string, null)
    default_action_type = optional(string, "forward")
    target_group_key    = optional(string, null)
    target_group_arn    = optional(string, null)
    redirect = optional(object({
      port        = optional(string, null)
      protocol    = optional(string, null)
      host        = optional(string, null)
      path        = optional(string, null)
      query       = optional(string, null)
      status_code = string
    }), null)
    fixed_response = optional(object({
      content_type = string
      message_body = optional(string, null)
      status_code  = string
    }), null)
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
# Extra Listener Certificates (SNI)
################################################################################

variable "extra_certificates" {
  description = "Map of additional certificates to associate with HTTPS listeners (SNI support)."
  type = map(object({
    listener_key    = string
    certificate_arn = string
  }))
  default = {}
}

################################################################################
# Listener Rules
################################################################################

variable "listener_rules" {
  description = "Map of listener rule definitions for path-based, host-based, or header-based routing."
  type = map(object({
    listener_key     = string
    priority         = optional(number, null)
    action_type      = optional(string, "forward")
    target_group_key = optional(string, null)
    target_group_arn = optional(string, null)
    redirect = optional(object({
      port        = optional(string, null)
      protocol    = optional(string, null)
      host        = optional(string, null)
      path        = optional(string, null)
      query       = optional(string, null)
      status_code = string
    }), null)
    fixed_response = optional(object({
      content_type = string
      message_body = optional(string, null)
      status_code  = string
    }), null)
    conditions = optional(object({
      path_patterns        = optional(list(string), [])
      host_headers         = optional(list(string), [])
      http_request_methods = optional(list(string), [])
      source_ips           = optional(list(string), [])
      http_headers = optional(list(object({
        http_header_name = string
        values           = list(string)
      })), [])
      query_strings = optional(list(object({
        key   = optional(string, null)
        value = string
      })), [])
    }), {})
    tags = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# WAF Integration
################################################################################

variable "waf_web_acl_arn" {
  description = "The ARN of a WAFv2 Web ACL to associate with the Application Load Balancer."
  type        = string
  default     = null
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "A map of tags to assign to all resources created by this module."
  type        = map(string)
  default     = {}
}
