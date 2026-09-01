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

variable "pem_certificate" {
  description = "The certificate chain in PEM-encoded form. Leaf certificate first, followed by any intermediates."
  type        = string
}

variable "pem_private_key" {
  description = "The private key of the leaf certificate, in PEM-encoded form."
  type        = string
}
