variable "project_id" {
  type = string
}

variable "subnet" {
  type = map(object({
    name                     = string
    region                   = string
    network                  = string
    ip_cidr_range            = string
    description              = optional(string, "")
    private_ip_google_access = optional(bool, false)
    flow_logs                = optional(bool, false)
    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
  }))
}
