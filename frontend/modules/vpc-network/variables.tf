variable "project_id" {
  type = string
}

variable "vpc_network" {
  type = map(object({
    name                            = string
    description                     = optional(string, "")
    auto_create_subnetworks         = optional(bool, false)
    routing_mode                    = optional(string, "GLOBAL")
    mtu                             = optional(number, 1460)
    delete_default_routes_on_create = optional(bool, false)
  }))
}
