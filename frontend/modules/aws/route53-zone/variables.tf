variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "route53_zone" {
  description = "Map of Route 53 hosted zones to create, keyed by domain name."
  type = map(object({
    name              = optional(string, "")
    comment           = optional(string)
    force_destroy     = optional(bool, false)
    delegation_set_id = optional(string)
    vpc_associations = optional(list(object({
      vpc_id     = string
      vpc_region = optional(string)
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for z in values(var.route53_zone) : z.delegation_set_id == null || length(z.vpc_associations) == 0
    ])
    error_message = "delegation_set_id is only valid for a public hosted zone; it can't be set alongside vpc_associations."
  }
}
