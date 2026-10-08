variable "project_id" {
  description = "The GCP project ID in which the DNS record will be created."
  type        = string
}

variable "managed_zone" {
  description = "The name of the managed zone in which the record set will be created."
  type        = string
}

variable "name" {
  description = "The fully qualified domain name of the record set, ending with a trailing dot."
  type        = string
}

variable "type" {
  description = "The DNS record set type (e.g., A, AAAA, CAA, CNAME, DNSKEY, DS, HTTPS, IPSECVPNKEY, MX, NAPTR, NS, PTR, SOA, SPF, SRV, SSHFP, SVCB, TLSA, TXT)."
  type        = string
}
variable "ttl" {
  type    = number
  default = 300
}
variable "rrdatas" {
  type    = list(string)
  default = []
}
variable "routing_policy_type" {
  type    = string
  default = "none"
}
variable "dnssec_enabled" {
  type    = bool
  default = false
}
variable "routing_health_check" {
  type    = string
  default = null
}
variable "wrr_targets" {
  type = list(object({
    weight                            = number
    rrdatas                           = optional(list(string), [])
    health_checked_external_endpoints = optional(list(string), [])
  }))
  default = []
}
variable "geo_targets" {
  type = list(object({
    location                          = string
    rrdatas                           = optional(list(string), [])
    health_checked_external_endpoints = optional(list(string), [])
  }))
  default = []
}
