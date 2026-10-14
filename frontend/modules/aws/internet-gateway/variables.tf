variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "internet_gateway" {
  description = "Map of Internet Gateway configurations to deploy, keyed by name."
  type = map(object({
    name                       = optional(string, null)
    vpc_id                     = optional(string, null)
    create_egress_only_gateway = optional(bool, false)
    tags                       = optional(map(string), {})
  }))
  default = {}
}
