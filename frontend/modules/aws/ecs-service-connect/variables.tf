variable "region" {
  description = "The AWS Region in which the resources will be created."
  type        = string
}

variable "ecs_service_connect" {
  description = "Cloud Map HTTP namespaces for ECS Service Connect, keyed by namespace name."
  type = map(object({
    name        = string
    description = optional(string)
    tags        = optional(map(string), {})
  }))
  default = {}
}
