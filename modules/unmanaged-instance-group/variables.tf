variable "name" {
  type        = string
  description = "The name of the instance group."
}

variable "description" {
  type        = string
  description = "An optional description of this resource."
  default     = null
}

variable "project_id" {
  type        = string
  description = "The ID of the project in which the resource belongs."
  default     = null
}

variable "zone" {
  type        = string
  description = "The zone that this instance group should be created in."
}

variable "network" {
  type        = string
  description = "Name of the network the instance group is in. Leave unset to let Compute Engine infer it from the member instances."
  default     = null
}

variable "instances" {
  type        = list(string)
  description = "Names of existing instances to place in the group. They must already exist in the same zone."
  default     = []
}

variable "named_ports" {
  type = list(object({
    name = string
    port = number
  }))
  description = "The named port configuration."
  default     = []
}
