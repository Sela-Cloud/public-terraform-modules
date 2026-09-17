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
    zone_type        = optional(string, "standard")
    forwarding_targets = optional(list(object({
      ipv4_address    = optional(string)
      ipv6_address    = optional(string)
      domain_name     = optional(string)
      forwarding_path = optional(string, "default")
    })), [])
    peering_target_project = optional(string)
    peering_target_network = optional(string)
    dnssec_state           = optional(string, "off")
    dnssec_non_existence   = optional(string)
    dnssec_default_key_specs = optional(list(object({
      key_type   = string
      algorithm  = string
      key_length = optional(number)
    })), [])
    enable_logging = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for zone in values(var.cloud_dns_zone) : contains(["public", "private"], zone.visibility) && contains(["standard", "forwarding", "peering"], zone.zone_type)
    ])
    error_message = "Cloud DNS zones must use public/private visibility and standard, forwarding, or peering type."
  }

  validation {
    condition = alltrue([
      for zone in values(var.cloud_dns_zone) :
      zone.visibility != "private" || length(zone.private_networks) > 0
    ])
    error_message = "Private Cloud DNS zones require at least one VPC network."
  }

  validation {
    condition = alltrue([
      for zone in values(var.cloud_dns_zone) :
      zone.zone_type == "standard" || (zone.visibility == "private" && length(zone.private_networks) > 0)
    ])
    error_message = "Forwarding and peering zones must be private and bound to at least one VPC network."
  }

  validation {
    condition = alltrue([
      for zone in values(var.cloud_dns_zone) :
      zone.zone_type != "forwarding" || (
        length(zone.forwarding_targets) > 0 &&
        alltrue([
          for target in zone.forwarding_targets :
          length(compact([target.ipv4_address, target.ipv6_address, target.domain_name])) == 1 &&
          contains(["default", "private"], target.forwarding_path)
        ]) &&
        (length([for target in zone.forwarding_targets : target.domain_name if target.domain_name != null && trimspace(target.domain_name) != ""]) == 0 || length(zone.forwarding_targets) == 1)
      )
    ])
    error_message = "Forwarding zones need one address type per target, valid forwarding paths, and either IP targets or exactly one FQDN target."
  }

  validation {
    condition = alltrue([
      for zone in values(var.cloud_dns_zone) :
      zone.zone_type != "peering" || (
        try(trimspace(zone.peering_target_project), "") != "" &&
        try(trimspace(zone.peering_target_network), "") != ""
      )
    ])
    error_message = "Peering zones require a target project and VPC network."
  }

  validation {
    condition = alltrue([
      for zone in values(var.cloud_dns_zone) :
      contains(["off", "on", "transfer"], zone.dnssec_state) &&
      (try(trimspace(zone.dnssec_non_existence), "") == "" || contains(["nsec", "nsec3"], zone.dnssec_non_existence)) &&
      (length(zone.dnssec_default_key_specs) == 0 || (
        length(zone.dnssec_default_key_specs) == 2 &&
        length(distinct([for spec in zone.dnssec_default_key_specs : spec.key_type])) == 2 &&
        alltrue([for spec in zone.dnssec_default_key_specs : contains(["keySigning", "zoneSigning"], spec.key_type) && contains(["ecdsap256sha256", "ecdsap384sha384", "rsasha1", "rsasha256", "rsasha512"], spec.algorithm)])
      ))
    ])
    error_message = "DNSSEC uses off, on, or transfer state; optional key specs must include one keySigning and one zoneSigning key with supported algorithms. Existing-zone DNSSEC key changes require DNSSEC to be off; this is enforced by the provider and GCP API at apply time."
  }
}
