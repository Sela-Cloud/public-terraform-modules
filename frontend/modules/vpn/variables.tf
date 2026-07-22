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
    local_traffic_selector  = optional(list(string), ["0.0.0.0/0"])
    remote_traffic_selector = optional(list(string), ["0.0.0.0/0"])
  }))
}
