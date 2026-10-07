variable "zone_id" {
  description = "Hosted zone to create the record in."
  type        = string
}

variable "name" {
  description = "Record name, e.g. www.example.com or example.com for the apex."
  type        = string
}

variable "type" {
  description = "DNS record type."
  type        = string

  validation {
    condition = contains(
      ["A", "AAAA", "CNAME", "MX", "TXT", "NS", "SOA", "SRV", "PTR", "CAA", "DS", "NAPTR", "HTTPS", "SVCB", "TLSA"],
      var.type
    )
    error_message = "type must be one of the DNS record types Route 53 supports."
  }
}

variable "is_alias" {
  description = "Route to an AWS resource (CloudFront, ALB, S3 website endpoint, another record) by alias instead of a plain value/TTL."
  type        = bool
  default     = false
}

variable "alias_name" {
  description = "DNS name of the alias target (e.g. the CloudFront distribution's domain name). Required when is_alias is true."
  type        = string
  default     = null
}

variable "alias_zone_id" {
  description = "Hosted zone ID of the alias target. Required when is_alias is true."
  type        = string
  default     = null
}

variable "alias_evaluate_target_health" {
  description = "Whether this record responds to DNS queries with the alias target's health, for use with failover routing."
  type        = bool
  default     = false
}

variable "ttl" {
  description = "Time to live, in seconds. Ignored when is_alias is true."
  type        = number
  default     = 300
}

variable "records" {
  description = "Record values. Ignored when is_alias is true."
  type        = list(string)
  default     = []
}

variable "routing_policy_type" {
  description = "Routing policy for this record."
  type        = string
  default     = "SIMPLE"

  validation {
    condition = contains(
      ["SIMPLE", "WEIGHTED", "LATENCY", "FAILOVER", "GEOLOCATION", "GEOPROXIMITY", "CIDR", "MULTIVALUE"],
      var.routing_policy_type
    )
    error_message = "routing_policy_type must be one of SIMPLE, WEIGHTED, LATENCY, FAILOVER, GEOLOCATION, GEOPROXIMITY, CIDR, MULTIVALUE."
  }
}

variable "set_identifier" {
  description = "Distinguishes this record from others with the same name/type sharing a routing policy. Required for any routing_policy_type other than SIMPLE."
  type        = string
  default     = null
}

variable "health_check_id" {
  description = "Health check to associate with this record."
  type        = string
  default     = null
}

variable "weighted_weight" {
  description = "Relative weight for WEIGHTED routing."
  type        = number
  default     = null
}

variable "latency_region" {
  description = "AWS region this record represents for LATENCY routing."
  type        = string
  default     = null
}

variable "failover_type" {
  description = "PRIMARY or SECONDARY, for FAILOVER routing."
  type        = string
  default     = null

  validation {
    condition     = var.failover_type == null || contains(["PRIMARY", "SECONDARY"], var.failover_type)
    error_message = "failover_type must be 'PRIMARY' or 'SECONDARY'."
  }
}

variable "geolocation_continent" {
  description = "Continent code for GEOLOCATION routing. Mutually exclusive with country/subdivision."
  type        = string
  default     = null
}

variable "geolocation_country" {
  description = "Country code for GEOLOCATION routing."
  type        = string
  default     = null
}

variable "geolocation_subdivision" {
  description = "US state subdivision code for GEOLOCATION routing. Requires country to be 'US'."
  type        = string
  default     = null
}

variable "geoproximity_aws_region" {
  description = "AWS region bias origin for GEOPROXIMITY routing. Mutually exclusive with explicit coordinates."
  type        = string
  default     = null
}

variable "geoproximity_bias" {
  description = "Expands (positive) or shrinks (negative) the geographic region for this resource, -99 to 99."
  type        = number
  default     = null
}

variable "geoproximity_local_zone_group" {
  description = "Local Zone group bias origin for GEOPROXIMITY routing."
  type        = string
  default     = null
}

variable "geoproximity_latitude" {
  description = "Latitude of the bias origin for GEOPROXIMITY routing, as a string (e.g. \"49.22\")."
  type        = string
  default     = null
}

variable "geoproximity_longitude" {
  description = "Longitude of the bias origin for GEOPROXIMITY routing, as a string (e.g. \"-122.19\")."
  type        = string
  default     = null
}

variable "cidr_collection_id" {
  description = "CIDR collection ID for CIDR routing."
  type        = string
  default     = null
}

variable "cidr_location_name" {
  description = "Location name within the CIDR collection for CIDR routing."
  type        = string
  default     = null
}

variable "allow_overwrite" {
  description = "Allow overwriting an existing record of the same name/type not managed by this Terraform run."
  type        = bool
  default     = false
}
