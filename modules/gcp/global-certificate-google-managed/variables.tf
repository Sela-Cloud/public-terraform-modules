variable "project_id" {
  description = "Project where the certificate is created."
  type        = string
}

variable "name" {
  description = "Name of the certificate."
  type        = string
}

variable "description" {
  description = "Description of the certificate."
  type        = string
  default     = null
}

variable "domain_names" {
  description = "Domains for which the Google-managed certificate will be issued. Wildcard domains require DNS Authorization."
  type        = list(string)

  validation {
    condition     = length(var.domain_names) > 0
    error_message = "At least one domain name is required."
  }
}

variable "authorization_type" {
  description = "How domain ownership is proven: 'dns_authorization' (via a DNS Authorization resource) or 'load_balancer_authorization' (domains already served by a Google Cloud load balancer)."
  type        = string

  validation {
    condition     = contains(["dns_authorization", "load_balancer_authorization"], var.authorization_type)
    error_message = "authorization_type must be 'dns_authorization' or 'load_balancer_authorization'."
  }
}

variable "dns_authorization_names" {
  description = "Names of existing DNS Authorization resources covering domain_names. Required when authorization_type is 'dns_authorization'."
  type        = list(string)
  default     = []
}
