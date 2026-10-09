variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "acm" {
  description = "Map of AWS ACM Certificate configurations to deploy, keyed by domain or certificate name."
  type = map(object({
    name                      = optional(string, "acm-certificate-default")
    domain_name               = optional(string, "example.com")
    validation_method         = optional(string, "DNS")
    subject_alternative_names = optional(list(string), [])
    key_algorithm             = optional(string, "RSA_2048")
    certificate_authority_arn = optional(string, null)
    create_route53_records    = optional(bool, false)
    zone_id                   = optional(string, null)
    validate_certificate      = optional(bool, false)
    tags                      = optional(map(string), {})
  }))
  default = {
    "acm-certificate-default" = {
      name                      = "acm-certificate-default"
      domain_name               = "example.com"
      validation_method         = "DNS"
      subject_alternative_names = []
      key_algorithm             = "RSA_2048"
      certificate_authority_arn = null
      create_route53_records    = false
      zone_id                   = null
      validate_certificate      = false
      tags                      = {}
    }
  }
}
