variable "project_id" { type = string }

variable "private_service_access" {
  type = map(object({
    name          = string
    network       = string
    prefix_length = optional(number, 20)
    address       = optional(string)
  }))
  default = {}

  validation {
    condition     = alltrue([for access in values(var.private_service_access) : access.prefix_length >= 16 && access.prefix_length <= 24])
    error_message = "Private Service Access prefix_length must be between /16 and /24."
  }

  validation {
    condition     = length(distinct([for access in values(var.private_service_access) : access.network])) == length(values(var.private_service_access))
    error_message = "Create only one Private Service Access entry per VPC network. Add or manage further ranges through that existing shared connection."
  }
}
