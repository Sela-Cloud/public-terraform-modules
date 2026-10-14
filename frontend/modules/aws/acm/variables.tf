variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
}

variable "acm" {
  description = "Map of AWS ACM Certificate configurations to deploy, keyed by domain or certificate name."
  type = map(object({
    name                      = string
    domain_name               = string
    validation_method         = optional(string, "DNS")
    subject_alternative_names = optional(list(string), [])
    key_algorithm             = optional(string, "RSA_2048")
    certificate_authority_arn = optional(string, null)
    create_route53_records    = optional(bool, false)
    zone_id                   = optional(string, null)
    validate_certificate      = optional(bool, false)
    tags                      = optional(map(string), {})
  }))
  default = {}
}
