variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "security_group" {
  description = "Map of AWS Security Group configurations to deploy, keyed by security group name."
  type = map(object({
    name                   = optional(string, "security-group-default")
    description            = optional(string, "Managed by Terraform")
    vpc_id                 = string
    revoke_rules_on_delete = optional(bool, false)
    ingress_rules = optional(list(object({
      description                  = optional(string, null)
      from_port                    = optional(number, null)
      to_port                      = optional(number, null)
      ip_protocol                  = optional(string, "tcp")
      cidr_ipv4                    = optional(string, null)
      cidr_ipv6                    = optional(string, null)
      referenced_security_group_id = optional(string, null)
    })), [])
    egress_rules = optional(list(object({
      description                  = optional(string, null)
      from_port                    = optional(number, null)
      to_port                      = optional(number, null)
      ip_protocol                  = optional(string, "-1")
      cidr_ipv4                    = optional(string, "0.0.0.0/0")
      cidr_ipv6                    = optional(string, null)
      referenced_security_group_id = optional(string, null)
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}
