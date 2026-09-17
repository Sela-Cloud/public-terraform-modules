variable "project_id" {
  type = string
}

variable "vpn" {
  type = map(object({
    name                    = string
    region                  = string
    network                 = string
    peer_ip                 = string
    shared_secret           = string
    ike_version             = optional(number, 2)
    routing_mode            = optional(string, "POLICY_BASED")
    destination_ranges      = optional(list(string), [])
    local_traffic_selector  = optional(list(string), [])
    remote_traffic_selector = optional(list(string), [])
    description             = optional(string, "")
  }))

  validation {
    condition = alltrue([
      for v in values(var.vpn) : contains(["ROUTE_BASED", "POLICY_BASED"], v.routing_mode)
    ])
    error_message = "routing_mode must be 'ROUTE_BASED' or 'POLICY_BASED'."
  }

  validation {
    condition = alltrue([
      for v in values(var.vpn) : v.routing_mode != "ROUTE_BASED" || length(v.destination_ranges) > 0
    ])
    error_message = "destination_ranges must have at least one entry when routing_mode is ROUTE_BASED."
  }

  validation {
    condition = alltrue([
      for v in values(var.vpn) : v.routing_mode != "POLICY_BASED" || (
        length(v.local_traffic_selector) > 0 &&
        length(v.remote_traffic_selector) > 0 &&
        !contains(v.local_traffic_selector, "0.0.0.0/0") &&
        !contains(v.remote_traffic_selector, "0.0.0.0/0")
      )
    ])
    error_message = "local_traffic_selector and remote_traffic_selector must be set to specific CIDRs (not 0.0.0.0/0) when routing_mode is POLICY_BASED."
  }
}
