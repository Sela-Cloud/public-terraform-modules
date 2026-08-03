variable "project_id" {
  type = string
}

variable "cloud_dns_zone" {
  type = map(object({
    name             = string
    dns_name         = string
    visibility       = optional(string, "public")
    description      = optional(string)
    labels           = optional(map(string), {})
    private_networks = optional(list(string), [])
    enable_logging   = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for zone in values(var.cloud_dns_zone) : contains(["public", "private"], zone.visibility)
    ])
    error_message = "Cloud DNS Phase 1 supports public and private standard managed zones only."
  }

  validation {
    condition = alltrue([
      for zone in values(var.cloud_dns_zone) :
      zone.visibility != "private" || length(zone.private_networks) > 0
    ])
    error_message = "Private Cloud DNS zones require at least one VPC network."
  }
}
