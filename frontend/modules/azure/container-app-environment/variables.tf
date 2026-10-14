variable "container_app_environment" {
  description = "Map of Azure Container App Environment configurations to create."
  type = map(object({
    name                                        = string
    resource_group_name                         = string
    location                                    = string
    log_analytics_workspace_id                  = optional(string, null)
    logs_destination                            = optional(string, "log-analytics")
    infrastructure_subnet_id                    = optional(string, null)
    infrastructure_resource_group_name          = optional(string, null)
    internal_load_balancer_enabled              = optional(bool, false)
    zone_redundancy_enabled                     = optional(bool, false)
    mutual_tls_enabled                          = optional(bool, false)
    public_network_access                       = optional(string, "Enabled")
    dapr_application_insights_connection_string = optional(string, null)
    workload_profiles = optional(list(object({
      name                  = string
      workload_profile_type = string
      minimum_count         = optional(number, 0)
      maximum_count         = optional(number, 10)
    })), [])
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string), null)
    }), null)
    tags = optional(map(string), {})
  }))
  default = {}
}
