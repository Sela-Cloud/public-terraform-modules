variable "project_id" {
  type = string
}

variable "cloud_dns_record" {
  type = map(object({
    record_key           = string
    managed_zone         = string
    name                 = string
    type                 = string
    ttl                  = optional(number, 300)
    rrdatas              = optional(list(string), [])
    routing_policy_type  = optional(string, "none")
    dnssec_enabled       = optional(bool, false)
    routing_health_check = optional(string)
    wrr_targets = optional(list(object({
      weight                            = number
      rrdatas                           = optional(list(string), [])
      health_checked_external_endpoints = optional(list(string), [])
    })), [])
    geo_targets = optional(list(object({
      location                          = string
      rrdatas                           = optional(list(string), [])
      health_checked_external_endpoints = optional(list(string), [])
    })), [])
  }))
  default = {}

  validation {
    condition = length(distinct([
      for record in values(var.cloud_dns_record) : "${lower(trimsuffix(record.name, "."))}|${upper(record.type)}"
    ])) == length(var.cloud_dns_record)
    error_message = "Each Cloud DNS record must have a unique name and type combination."
  }

  validation {
    condition = alltrue([
      for record in values(var.cloud_dns_record) :
      !record.dnssec_enabled || alltrue(concat(
        [for target in record.wrr_targets : !(length(target.rrdatas) > 0 && length(target.health_checked_external_endpoints) > 0)],
        [for target in record.geo_targets : !(length(target.rrdatas) > 0 && length(target.health_checked_external_endpoints) > 0)]
      ))
    ])
    error_message = "For DNSSEC-enabled zones, each routing target must use record data or health-checked endpoints, not both."
  }

  validation {
    condition = alltrue([
      for record in values(var.cloud_dns_record) :
      contains(["none", "wrr", "geo"], record.routing_policy_type) &&
      ((record.routing_policy_type == "none" && length(record.rrdatas) > 0 && length(record.wrr_targets) == 0 && length(record.geo_targets) == 0) ||
        (record.routing_policy_type == "wrr" && length(record.rrdatas) == 0 && length(record.wrr_targets) > 0 && length(record.geo_targets) == 0) ||
      (record.routing_policy_type == "geo" && length(record.rrdatas) == 0 && length(record.geo_targets) > 0 && length(record.wrr_targets) == 0))
    ])
    error_message = "Standard records require rrdatas. WRR and GEO records require their matching routing targets and omit top-level rrdatas."
  }

  validation {
    condition = alltrue(flatten([
      for record in values(var.cloud_dns_record) : concat(
        [for target in record.wrr_targets : target.weight >= 0 && length(target.rrdatas) + length(target.health_checked_external_endpoints) > 0],
        [for target in record.geo_targets : length(target.rrdatas) + length(target.health_checked_external_endpoints) > 0]
      )
    ]))
    error_message = "Every routing target needs a non-negative WRR weight when applicable and record data or health-checked endpoints."
  }

  validation {
    condition = alltrue([
      for record in values(var.cloud_dns_record) :
      (length(flatten([for target in record.wrr_targets : target.health_checked_external_endpoints])) + length(flatten([for target in record.geo_targets : target.health_checked_external_endpoints])) == 0) ||
      (try(trimspace(record.routing_health_check), "") != "" && contains(["A", "AAAA"], upper(record.type)))
    ])
    error_message = "Health-checked routing targets require a Compute health check and A or AAAA record type."
  }

  validation {
    condition = alltrue([
      for record in values(var.cloud_dns_record) :
      upper(record.type) != "SRV" || alltrue([
        for value in concat(record.rrdatas, flatten([for target in record.wrr_targets : target.rrdatas]), flatten([for target in record.geo_targets : target.rrdatas])) :
        can(regex("^[0-9]+ [0-9]+ [0-9]+ .+\\.$", value))
      ])
    ])
    error_message = "SRV record data must be priority weight port target, with a trailing dot on the target."
  }

  validation {
    condition = alltrue([
      for record in values(var.cloud_dns_record) :
      upper(record.type) != "CAA" || alltrue([
        for value in concat(record.rrdatas, flatten([for target in record.wrr_targets : target.rrdatas]), flatten([for target in record.geo_targets : target.rrdatas])) :
        can(regex("^(0|128) (issue|issuewild|iodef) \\\".+\\\"$", value))
      ])
    ])
    error_message = "CAA record data must be flag tag value, for example: 0 issue \\\"letsencrypt.org\\\"."
  }

  validation {
    condition = alltrue([
      for record in values(var.cloud_dns_record) :
      upper(record.type) != "TXT" || alltrue([
        for value in concat(record.rrdatas, flatten([for target in record.wrr_targets : target.rrdatas]), flatten([for target in record.geo_targets : target.rrdatas])) :
        !strcontains(value, " ") || can(regex("^\\\".*\\\"$", value))
      ])
    ])
    error_message = "TXT record data containing spaces must be quoted."
  }

}
