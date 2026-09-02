variable "project_id" {
  type = string
}

variable "dns_authorization" {
  description = "Certificate Manager DNS authorizations configured through the Sela Deployer catalog."

  type = map(object({
    name        = string
    domain      = string
    description = optional(string)
    type        = optional(string, "FIXED_RECORD")
  }))
  default = {}

  validation {
    condition = alltrue([
      for a in values(var.dns_authorization) : contains(["FIXED_RECORD", "PER_PROJECT_RECORD"], a.type)
    ])
    error_message = "type must be 'FIXED_RECORD' or 'PER_PROJECT_RECORD'."
  }
}
