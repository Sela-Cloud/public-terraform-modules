variable "project_id" { type = string }
variable "managed_zone" { type = string }
variable "name" { type = string }
variable "type" { type = string }
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
