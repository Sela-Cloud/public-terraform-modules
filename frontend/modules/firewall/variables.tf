variable "project_id" {
  type = string
}

variable "firewall" {
  type = map(object({
    name               = string
    network            = string
    direction          = optional(string, "INGRESS")
    priority           = optional(number, 1000)
    description        = optional(string, "")
    source_ranges      = optional(list(string), [])
    destination_ranges = optional(list(string), [])
    source_tags        = optional(list(string), [])
    target_tags        = optional(list(string), [])
    disabled           = optional(bool, false)
    allow              = optional(list(object({ protocol = string, ports = optional(list(string), []) })), [])
    deny               = optional(list(object({ protocol = string, ports = optional(list(string), []) })), [])
  }))

  validation {
    condition     = alltrue([for rule in values(var.firewall) : (length(rule.allow) > 0) != (length(rule.deny) > 0)])
    error_message = "Each firewall rule must contain either allow or deny entries, but not both."
  }

  validation {
    condition     = alltrue([for rule in values(var.firewall) : rule.direction == "EGRESS" || length(rule.source_ranges) > 0 || length(rule.source_tags) > 0])
    error_message = "Ingress firewall rules require a source CIDR range or source network tag."
  }
}
