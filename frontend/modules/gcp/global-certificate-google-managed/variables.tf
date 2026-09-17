variable "project_id" {
  type = string
}

variable "global_certificate_google_managed" {
  description = "Google-managed Certificate Manager certificates configured through the Sela Deployer catalog."

  type = map(object({
    name                    = string
    description             = optional(string)
    domain_names            = list(string)
    authorization_type      = string
    dns_authorization_names = optional(list(string), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for cert in values(var.global_certificate_google_managed) : length(cert.domain_names) > 0
    ])
    error_message = "At least one domain name is required."
  }

  validation {
    condition = alltrue([
      for cert in values(var.global_certificate_google_managed) :
      contains(["dns_authorization", "load_balancer_authorization"], cert.authorization_type)
    ])
    error_message = "authorization_type must be 'dns_authorization' or 'load_balancer_authorization'."
  }

  validation {
    condition = alltrue([
      for cert in values(var.global_certificate_google_managed) :
      cert.authorization_type != "dns_authorization" || length(cert.dns_authorization_names) > 0
    ])
    error_message = "At least one DNS authorization is required when authorization_type is 'dns_authorization'."
  }
}
