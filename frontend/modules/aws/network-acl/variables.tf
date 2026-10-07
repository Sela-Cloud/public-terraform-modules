variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "network_acl" {
  description = "Map of AWS Network ACL configurations to deploy, keyed by network ACL name."
  type = map(object({
    name       = optional(string, "network-acl-default")
    vpc_id     = string
    subnet_ids = optional(list(string), [])
    ingress = optional(list(object({
      rule_no         = number
      action          = optional(string, "allow")
      protocol        = optional(string, "-1")
      from_port       = optional(number, 0)
      to_port         = optional(number, 0)
      cidr_block      = optional(string, null)
      ipv6_cidr_block = optional(string, null)
      icmp_type       = optional(number, null)
      icmp_code       = optional(number, null)
    })), [])
    egress = optional(list(object({
      rule_no         = number
      action          = optional(string, "allow")
      protocol        = optional(string, "-1")
      from_port       = optional(number, 0)
      to_port         = optional(number, 0)
      cidr_block      = optional(string, null)
      ipv6_cidr_block = optional(string, null)
      icmp_type       = optional(number, null)
      icmp_code       = optional(number, null)
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}
