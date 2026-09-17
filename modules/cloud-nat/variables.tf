variable "project_id" { type = string }
variable "name" { type = string }
variable "router" { type = string }
variable "region" { type = string }
variable "nat_ip_allocate_option" { type = string }
variable "nat_ips" { type = list(string) }
variable "drain_nat_ips" { type = list(string) }
variable "source_subnetwork_ip_ranges_to_nat" { type = string }
variable "subnetworks" { type = list(object({ name = string, source_ip_ranges_to_nat = list(string), secondary_ip_range_names = optional(list(string), []) })) }
variable "min_ports_per_vm" { type = number }
variable "max_ports_per_vm" { type = number }
variable "enable_endpoint_independent_mapping" { type = bool }
variable "enable_dynamic_port_allocation" { type = bool }
variable "auto_network_tier" { type = string }
variable "log_filter" { type = string }
