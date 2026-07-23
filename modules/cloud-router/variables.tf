variable "project_id" { type = string }
variable "name" { type = string }
variable "region" { type = string }
variable "network" { type = string }
variable "description" { type = string }
variable "asn" { type = number }
variable "advertise_mode" { type = string }
variable "advertised_groups" { type = list(string) }
variable "advertised_ip_ranges" { type = list(object({ range = string, description = optional(string, "") })) }
variable "keepalive_interval" { type = number }
variable "identifier_range" { type = string }
