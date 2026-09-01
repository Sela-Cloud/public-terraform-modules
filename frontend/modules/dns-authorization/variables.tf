variable "project_id" {
  type = string
}

variable "dns_authorization" {
  description = "Certificate Manager DNS authorizations configured through the Sela Deployer catalog."

  type = map(object({
    name        = string
    domain      = string
    description = optional(string)
  }))
  default = {}
}
