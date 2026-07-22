variable "project_id" { type = string }
variable "cloud_router" {
  type = map(object({
    name                 = string
    region               = string
    network              = string
    description          = optional(string, "")
    asn                  = optional(number, 64514)
    advertise_mode       = optional(string, "DEFAULT")
    advertised_groups    = optional(list(string), [])
    advertised_ip_ranges = optional(list(object({ range = string, description = optional(string, "") })), [])
    keepalive_interval   = optional(number)
    identifier_range     = optional(string)
  }))
}
