variable "project_id" { type = string }
variable "name" { type = string }
variable "dns_name" { type = string }
variable "visibility" {
  type    = string
  default = "public"
}
variable "description" {
  type    = string
  default = null
}
variable "labels" {
  type    = map(string)
  default = {}
}
variable "private_networks" {
  type    = list(string)
  default = []
}
variable "zone_type" {
  type    = string
  default = "standard"
}
variable "forwarding_targets" {
  type = list(object({
    ipv4_address    = optional(string)
    ipv6_address    = optional(string)
    domain_name     = optional(string)
    forwarding_path = optional(string, "default")
  }))
  default = []
}
variable "peering_target_project" {
  type    = string
  default = null
}
variable "peering_target_network" {
  type    = string
  default = null
}
variable "dnssec_state" {
  type    = string
  default = "off"
}
variable "dnssec_non_existence" {
  type    = string
  default = null
}
variable "dnssec_default_key_specs" {
  type = list(object({
    key_type   = string
    algorithm  = string
    key_length = optional(number)
  }))
  default = []
}
variable "enable_logging" {
  type    = bool
  default = false
}
