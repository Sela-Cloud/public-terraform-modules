variable "project_id" {
  type = string
}

variable "regional_internal_lb" {
  description = "Regional internal Application Load Balancers configured through the Sela Deployer catalog."

  type = map(object({
    name                  = string
    region                = string
    network               = string
    subnetwork            = string
    backend_project_id    = optional(string)
    existing_address_name = optional(string)
    address               = optional(string)
    certificate_names     = list(string)
    create_http_redirect  = optional(bool, false)
    allow_global_access   = optional(bool, false)
    labels                = optional(map(string), {})
    default_service       = string
    backend_services = optional(list(object({
      service_name              = string
      target_type               = string
      umig_name                 = optional(string)
      umig_zone                 = optional(string)
      mig_name                  = optional(string)
      neg_name                  = optional(string)
      cloud_run_service         = optional(string)
      port_name                 = optional(string, "http")
      timeout_sec               = optional(number, 30)
      enable_health_check       = optional(bool, false)
      health_check_type         = optional(string, "tcp")
      health_check_port         = optional(number, 80)
      health_check_request_path = optional(string, "/")
      # The provider's own defaults; see the child module for what each one controls.
      health_check_interval_sec        = optional(number, 5)
      health_check_timeout_sec         = optional(number, 5)
      health_check_healthy_threshold   = optional(number, 2)
      health_check_unhealthy_threshold = optional(number, 2)
    })), [])
    domains = optional(list(object({
      matcher_key     = string
      hosts           = list(string)
      default_service = string
      route_rules = optional(list(object({
        priority              = number
        service               = string
        paths                 = list(string)
        match_mode            = optional(string)
        path_rewrite          = optional(string)
        path_template_rewrite = optional(string)
      })), [])
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for lb in values(var.regional_internal_lb) :
      length(distinct([for s in lb.backend_services : s.service_name])) == length(lb.backend_services)
    ])
    error_message = "backend service names must be unique within one load balancer."
  }

  validation {
    condition = alltrue([
      for lb in values(var.regional_internal_lb) :
      length(distinct([for d in lb.domains : d.matcher_key])) == length(lb.domains)
    ])
    error_message = "domain matcher keys must be unique within one load balancer."
  }

  validation {
    condition = alltrue([
      for lb in values(var.regional_internal_lb) :
      alltrue([for s in lb.backend_services : contains(["umig", "mig", "neg", "cloud_run"], s.target_type)])
    ])
    error_message = "backend_services target_type must be 'umig', 'mig', 'neg', or 'cloud_run'."
  }

  validation {
    condition = alltrue(flatten([
      for lb in values(var.regional_internal_lb) : [
        for k in concat(
          [lb.default_service],
          [for d in lb.domains : d.default_service],
          flatten([for d in lb.domains : [for r in d.route_rules : r.service]])
        ) : contains([for s in lb.backend_services : s.service_name], k)
      ]
    ]))
    error_message = "Every default backend and route rule backend must match a backend service name in the same load balancer."
  }
}
