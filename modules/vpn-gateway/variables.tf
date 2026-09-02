variable "project_id" {
  description = "Project where the VPN gateway is created."
  type        = string
}

variable "name" {
  description = "Name of the VPN gateway."
  type        = string
}

variable "region" {
  description = "Region the gateway sits in."
  type        = string
}

variable "network" {
  description = "VPC network the gateway accepts traffic for."
  type        = string
}

variable "description" {
  description = "Description of the VPN gateway."
  type        = string
  default     = null
}

variable "existing_static_ip_name" {
  description = "Name of an existing regional google_compute_address to reuse. Leave unset to create a new one."
  type        = string
  default     = null
}
