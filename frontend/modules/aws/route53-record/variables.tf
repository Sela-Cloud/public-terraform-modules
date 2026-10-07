variable "region" {
  description = "The AWS region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "route53_record" {
  description = "Map of Route 53 records to create, keyed by an arbitrary resource name."
  type = map(object({
    zone_id                       = string
    name                          = string
    type                          = string
    is_alias                      = optional(bool, false)
    alias_name                    = optional(string)
    alias_zone_id                 = optional(string)
    alias_evaluate_target_health  = optional(bool, false)
    ttl                           = optional(number, 300)
    records                       = optional(list(string), [])
    routing_policy_type           = optional(string, "SIMPLE")
    set_identifier                = optional(string)
    health_check_id               = optional(string)
    weighted_weight               = optional(number)
    latency_region                = optional(string)
    failover_type                 = optional(string)
    geolocation_continent         = optional(string)
    geolocation_country           = optional(string)
    geolocation_subdivision       = optional(string)
    geoproximity_aws_region       = optional(string)
    geoproximity_bias             = optional(number)
    geoproximity_local_zone_group = optional(string)
    geoproximity_latitude         = optional(string)
    geoproximity_longitude        = optional(string)
    cidr_collection_id            = optional(string)
    cidr_location_name            = optional(string)
    allow_overwrite               = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for r in values(var.route53_record) :
      contains(["A", "AAAA", "CNAME", "MX", "TXT", "NS", "SOA", "SRV", "PTR", "CAA", "DS", "NAPTR", "HTTPS", "SVCB", "TLSA"], r.type)
    ])
    error_message = "type must be one of the DNS record types Route 53 supports."
  }

  validation {
    condition = alltrue([
      for r in values(var.route53_record) :
      contains(["SIMPLE", "WEIGHTED", "LATENCY", "FAILOVER", "GEOLOCATION", "GEOPROXIMITY", "CIDR", "MULTIVALUE"], r.routing_policy_type)
    ])
    error_message = "routing_policy_type must be one of SIMPLE, WEIGHTED, LATENCY, FAILOVER, GEOLOCATION, GEOPROXIMITY, CIDR, MULTIVALUE."
  }

  validation {
    condition = alltrue([
      for r in values(var.route53_record) : r.is_alias || (r.ttl != null && length(r.records) > 0)
    ])
    error_message = "ttl and records are required unless is_alias is true."
  }

  validation {
    condition = alltrue([
      for r in values(var.route53_record) : !r.is_alias || (r.alias_name != null && r.alias_zone_id != null)
    ])
    error_message = "alias_name and alias_zone_id are required when is_alias is true."
  }

  validation {
    condition = alltrue([
      for r in values(var.route53_record) : r.routing_policy_type == "SIMPLE" || r.set_identifier != null
    ])
    error_message = "set_identifier is required for any routing_policy_type other than SIMPLE."
  }

  validation {
    condition = alltrue([
      for r in values(var.route53_record) : r.routing_policy_type != "WEIGHTED" || r.weighted_weight != null
    ])
    error_message = "weighted_weight is required when routing_policy_type is WEIGHTED."
  }

  validation {
    condition = alltrue([
      for r in values(var.route53_record) : r.routing_policy_type != "LATENCY" || r.latency_region != null
    ])
    error_message = "latency_region is required when routing_policy_type is LATENCY."
  }

  validation {
    condition = alltrue([
      for r in values(var.route53_record) : r.routing_policy_type != "FAILOVER" || r.failover_type != null
    ])
    error_message = "failover_type is required when routing_policy_type is FAILOVER."
  }

  validation {
    condition = alltrue([
      for r in values(var.route53_record) :
      r.routing_policy_type != "CIDR" || (r.cidr_collection_id != null && r.cidr_location_name != null)
    ])
    error_message = "cidr_collection_id and cidr_location_name are required when routing_policy_type is CIDR."
  }

  validation {
    condition = alltrue([
      for r in values(var.route53_record) : r.geolocation_subdivision == null || r.geolocation_country == "US"
    ])
    error_message = "geolocation_subdivision requires geolocation_country to be 'US'."
  }
}
