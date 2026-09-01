variable "project_id" {
  type = string
}

variable "global_certificate_self_managed" {
  description = "Self-managed (bring-your-own) Certificate Manager certificates configured through the Sela Deployer catalog."

  type = map(object({
    name            = string
    description     = optional(string)
    pem_certificate = string
    pem_private_key = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for cert in values(var.global_certificate_self_managed) : trimspace(cert.pem_certificate) != ""
    ])
    error_message = "pem_certificate is required."
  }

  validation {
    condition = alltrue([
      for cert in values(var.global_certificate_self_managed) : trimspace(cert.pem_private_key) != ""
    ])
    error_message = "pem_private_key is required."
  }
}
