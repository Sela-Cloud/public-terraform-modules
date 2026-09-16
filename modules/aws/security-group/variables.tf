################################################################################
# AWS Security Group Variables
################################################################################

variable "name" {
  description = "Name of the security group."
  type        = string
  default     = "security-group-default"
}

variable "description" {
  description = "Security group description."
  type        = string
  default     = "Managed by Terraform"
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created."
  type        = string
}

variable "revoke_rules_on_delete" {
  description = "Instruct Terraform to revoke all the Security Group's rules before deleting the group itself."
  type        = bool
  default     = false
}

variable "ingress_rules" {
  description = "List of ingress rule definitions."
  type = list(object({
    description                  = optional(string, null)
    from_port                    = optional(number, null)
    to_port                      = optional(number, null)
    ip_protocol                  = optional(string, "tcp")
    cidr_ipv4                    = optional(string, null)
    cidr_ipv6                    = optional(string, null)
    referenced_security_group_id = optional(string, null)
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rule definitions."
  type = list(object({
    description                  = optional(string, null)
    from_port                    = optional(number, null)
    to_port                      = optional(number, null)
    ip_protocol                  = optional(string, "-1")
    cidr_ipv4                    = optional(string, "0.0.0.0/0")
    cidr_ipv6                    = optional(string, null)
    referenced_security_group_id = optional(string, null)
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
