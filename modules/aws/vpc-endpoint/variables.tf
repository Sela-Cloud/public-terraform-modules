################################################################################
# General / Core Configuration
################################################################################

variable "vpc_id" {
  description = "The ID of the VPC in which the VPC Endpoint(s) will be created. If null, the module falls back to the default VPC."
  type        = string
  default     = null
}

################################################################################
# Default / Shared Networking
################################################################################

variable "subnet_ids" {
  description = "Default list of subnet IDs across Availability Zones for Interface endpoints. Can be overridden per endpoint."
  type        = list(string)
  default     = []
}

variable "route_table_ids" {
  description = "Default list of route table IDs for Gateway endpoints (e.g. S3, DynamoDB). Can be overridden per endpoint."
  type        = list(string)
  default     = []
}

################################################################################
# Security Groups (For Interface Endpoints)
################################################################################

variable "security_group_ids" {
  description = "Default list of Security Group IDs to associate with Interface endpoints."
  type        = list(string)
  default     = []
}

variable "create_security_group" {
  description = "Whether to create a dedicated Security Group for Interface endpoints."
  type        = bool
  default     = false
}

variable "security_group_name" {
  description = "Name for the dedicated Security Group. Defaults to 'vpc-endpoints-sg' if not specified."
  type        = string
  default     = null
}

variable "security_group_description" {
  description = "Description for the dedicated Security Group."
  type        = string
  default     = "Security group for VPC Interface Endpoints"
}

variable "security_group_ingress_rules" {
  description = "List of ingress rules for the dedicated Security Group."
  type = list(object({
    description                  = optional(string, null)
    from_port                    = optional(number, 443)
    to_port                      = optional(number, 443)
    ip_protocol                  = optional(string, "tcp")
    cidr_ipv4                    = optional(string, "0.0.0.0/0")
    cidr_ipv6                    = optional(string, null)
    referenced_security_group_id = optional(string, null)
  }))
  default = [
    {
      description = "Allow HTTPS inbound from within VPC"
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
# Endpoints Definition Map
################################################################################

variable "endpoints" {
  description = "Map of VPC Endpoint configurations to create. Keyed by a user-friendly endpoint identifier."
  type = map(object({
    service             = optional(string, null)
    service_name        = optional(string, null)
    service_type        = optional(string, "Interface")
    service_region      = optional(string, null)
    private_dns_enabled = optional(bool, null)
    auto_accept         = optional(bool, true)
    route_table_ids     = optional(list(string), null)
    subnet_ids          = optional(list(string), null)
    subnet_configuration = optional(list(object({
      subnet_id = string
      ipv4      = optional(string, null)
      ipv6      = optional(string, null)
    })), null)
    security_group_ids         = optional(list(string), null)
    policy                     = optional(string, null)
    ip_address_type            = optional(string, null)
    resource_configuration_arn = optional(string, null)
    service_network_arn        = optional(string, null)
    dns_options = optional(object({
      dns_record_ip_type                             = optional(string, null)
      private_dns_only_for_inbound_resolver_endpoint = optional(bool, null)
      private_dns_preference                         = optional(string, null)
      private_dns_specified_domains                  = optional(list(string), null)
    }), null)
    timeouts = optional(object({
      create = optional(string, null)
      update = optional(string, null)
      delete = optional(string, null)
    }), null)
    tags = optional(map(string), {})
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
