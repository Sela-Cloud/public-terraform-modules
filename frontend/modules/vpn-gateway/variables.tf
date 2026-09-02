variable "project_id" {
  type = string
}

variable "vpn_gateway" {
  description = "Classic VPN gateways configured through the Sela Deployer catalog."

  type = map(object({
    name                    = string
    region                  = string
    network                 = string
    existing_static_ip_name = optional(string)
    description             = optional(string, "")
  }))
  default = {}
}
