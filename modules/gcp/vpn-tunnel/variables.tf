variable "project_id" { type = string }
variable "name" { type = string }
variable "region" { type = string }
variable "network" { type = string }
variable "gateway_name" {
  description = "Name of the vpn-gateway this tunnel attaches to."
  type        = string
}
variable "peer_ip" { type = string }
variable "shared_secret" { type = string }
variable "ike_version" { type = number }
variable "local_traffic_selector" { type = list(string) }
variable "remote_traffic_selector" { type = list(string) }
variable "description" { type = string }

variable "routing_mode" {
  description = "ROUTE_BASED or POLICY_BASED. Not a real GCP attribute -- GCP derives the mode from the tunnel's traffic selectors (0.0.0.0/0 on both sides = route-based); this field decides what this module does with those selectors and whether it creates routes."
  type        = string
  default     = "POLICY_BASED"

  validation {
    condition     = contains(["ROUTE_BASED", "POLICY_BASED"], var.routing_mode)
    error_message = "routing_mode must be 'ROUTE_BASED' or 'POLICY_BASED'."
  }
}

variable "destination_ranges" {
  description = "Remote CIDR ranges to route into the tunnel. Only used when routing_mode is ROUTE_BASED; one google_compute_route is created per entry."
  type        = list(string)
  default     = []
}
