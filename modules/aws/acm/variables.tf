variable "name" {
  description = "Name identifier applied as the 'Name' tag."
  type        = string
  default     = "acm-certificate-default"
}

variable "domain_name" {
  description = "A domain name for which the certificate should be issued."
  type        = string
  default     = "example.com"
}

variable "validation_method" {
  description = "Which method to use for certificate validation. Valid values: 'DNS', 'EMAIL'."
  type        = string
  default     = "DNS"

  validation {
    condition     = contains(["DNS", "EMAIL"], var.validation_method)
    error_message = "The validation_method must be either 'DNS' or 'EMAIL'."
  }
}

variable "subject_alternative_names" {
  description = "Set of domains that should be SANs in the issued certificate."
  type        = list(string)
  default     = []
}

variable "key_algorithm" {
  description = "The algorithm of the public and private key pair (e.g. 'RSA_2048', 'ECDSA_P256')."
  type        = string
  default     = "RSA_2048"
}

variable "certificate_authority_arn" {
  description = "The ARN of an AWS Certificate Manager Private CA (ACM PCA)."
  type        = string
  default     = null
}

variable "create_route53_records" {
  description = "Whether to automatically create Route 53 DNS validation records."
  type        = bool
  default     = false
}

variable "zone_id" {
  description = "The Route 53 Hosted Zone ID in which to create validation DNS records."
  type        = string
  default     = null
}

variable "validate_certificate" {
  description = "Whether to wait for certificate validation completion."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the certificate."
  type        = map(string)
  default     = {}
}
