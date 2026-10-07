################################################################################
# AWS Network ACL Variables
################################################################################

variable "name" {
  description = "Name to be used on all resources as identifier, applied as the 'Name' tag."
  type        = string
  default     = "network-acl-default"
}

variable "vpc_id" {
  description = "The ID of the associated VPC."
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "A list of Subnet IDs to apply the ACL to."
  type        = list(string)
  default     = []
}

variable "ingress" {
  description = "Specifies ingress rules for the network ACL."
  type = list(object({
    rule_no         = number
    action          = optional(string, "allow")
    protocol        = optional(string, "-1")
    from_port       = optional(number, 0)
    to_port         = optional(number, 0)
    cidr_block      = optional(string, null)
    ipv6_cidr_block = optional(string, null)
    icmp_type       = optional(number, null)
    icmp_code       = optional(number, null)
  }))
  default = []
}

variable "egress" {
  description = "Specifies egress rules for the network ACL."
  type = list(object({
    rule_no         = number
    action          = optional(string, "allow")
    protocol        = optional(string, "-1")
    from_port       = optional(number, 0)
    to_port         = optional(number, 0)
    cidr_block      = optional(string, null)
    ipv6_cidr_block = optional(string, null)
    icmp_type       = optional(number, null)
    icmp_code       = optional(number, null)
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
