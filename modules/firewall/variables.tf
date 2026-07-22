variable "project_id" {
  description = "The GCP project that owns the firewall rules."
  type        = string
}

variable "firewall" {
  description = "Firewall rule definitions, keyed by rule name."
  type = map(object({
    name                    = string
    network                 = string
    direction               = optional(string, "INGRESS")
    priority                = optional(number, 1000)
    description             = optional(string, "")
    source_ranges           = optional(list(string), [])
    destination_ranges      = optional(list(string), [])
    source_tags             = optional(list(string), [])
    source_service_accounts = optional(list(string), [])
    target_tags             = optional(list(string), [])
    target_service_accounts = optional(list(string), [])
    disabled                = optional(bool, false)
    enable_logging          = optional(bool, false)
    logging_metadata        = optional(string, "INCLUDE_ALL_METADATA")
    allow                   = optional(list(object({ protocol = string, ports = optional(list(string), []) })), [])
    deny                    = optional(list(object({ protocol = string, ports = optional(list(string), []) })), [])
  }))

  validation {
    condition     = alltrue([for rule in values(var.firewall) : (length(rule.allow) > 0) != (length(rule.deny) > 0)])
    error_message = "Each firewall rule must contain either allow or deny entries, but not both."
  }

  validation {
    condition     = alltrue([for rule in values(var.firewall) : rule.direction == "EGRESS" || length(rule.source_ranges) > 0 || length(rule.source_tags) > 0 || length(rule.source_service_accounts) > 0])
    error_message = "Ingress firewall rules require source ranges, source tags, or source service accounts."
  }
}
