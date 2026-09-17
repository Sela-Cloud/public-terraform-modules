variable "project_id" { type = string }
variable "name" { type = string }
variable "network" { type = string }
variable "direction" { type = string }
variable "priority" { type = number }
variable "description" { type = string }
variable "source_ranges" { type = list(string) }
variable "destination_ranges" { type = list(string) }
variable "source_tags" { type = list(string) }
variable "source_service_accounts" { type = list(string) }
variable "target_tags" { type = list(string) }
variable "target_service_accounts" { type = list(string) }
variable "disabled" { type = bool }
variable "enable_logging" { type = bool }
variable "logging_metadata" { type = string }
variable "allow" { type = list(object({ protocol = string, ports = optional(list(string), []) })) }
variable "deny" { type = list(object({ protocol = string, ports = optional(list(string), []) })) }
