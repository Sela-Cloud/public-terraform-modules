variable "project_id" {
  type = string
}

variable "global_external_alb" {
  description = "Global external Application Load Balancers configured through the Sela Deployer catalog."

  type = map(object({
    name                    = string
    backend_project_id      = optional(string)
    existing_static_ip_name = optional(string)
    certificate_map_name    = string
    create_http_redirect    = optional(bool, true)
    default_service = object({
      type = string
      key  = string
    })
    backend_buckets = optional(list(object({
      bucket_name     = string
      gcs_bucket_name = string
      description     = optional(string)
      enable_cdn      = optional(bool, false)
      cdn_policy = optional(object({
        cache_mode        = optional(string, "CACHE_ALL_STATIC")
        default_ttl       = optional(number)
        max_ttl           = optional(number)
        client_ttl        = optional(number)
        negative_caching  = optional(bool)
        serve_while_stale = optional(number)
        cache_key_policy = optional(object({
          include_http_headers   = optional(list(string), [])
          query_string_whitelist = optional(list(string), [])
        }), {})
      }))
    })), [])
    backend_services = optional(list(object({
      service_name        = string
      target_type         = string
      umig_name           = optional(string)
      umig_zone           = optional(string)
      neg_name            = optional(string)
      neg_region          = optional(string)
      mig_name            = optional(string)
      mig_region          = optional(string)
      port_name           = optional(string, "http")
      enable_health_check = optional(bool, false)
      health_check_port   = optional(number, 80)
      enable_cdn          = optional(bool, false)
      cdn_policy = optional(object({
        cache_mode        = optional(string, "CACHE_ALL_STATIC")
        default_ttl       = optional(number)
        max_ttl           = optional(number)
        client_ttl        = optional(number)
        negative_caching  = optional(bool)
        serve_while_stale = optional(number)
        cache_key_policy = optional(object({
          include_host           = optional(bool)
          include_protocol       = optional(bool)
          include_query_string   = optional(bool)
          query_string_blacklist = optional(list(string), [])
          query_string_whitelist = optional(list(string), [])
          include_http_headers   = optional(list(string), [])
          include_named_cookies  = optional(list(string), [])
        }), {})
      }))
    })), [])
    domains = optional(list(object({
      matcher_key = string
      hosts       = list(string)
      default_service = object({
        type = string
        key  = string
      })
      route_rules = optional(list(object({
        priority = number
        service = object({
          type = string
          key  = string
        })
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
      for alb in values(var.global_external_alb) :
      length(distinct([for b in alb.backend_buckets : b.bucket_name])) == length(alb.backend_buckets)
    ])
    error_message = "backend bucket names must be unique within one load balancer."
  }

  validation {
    condition = alltrue([
      for alb in values(var.global_external_alb) :
      length(distinct([for s in alb.backend_services : s.service_name])) == length(alb.backend_services)
    ])
    error_message = "backend service names must be unique within one load balancer."
  }

  validation {
    condition = alltrue([
      for alb in values(var.global_external_alb) :
      length(distinct([for d in alb.domains : d.matcher_key])) == length(alb.domains)
    ])
    error_message = "domain matcher keys must be unique within one load balancer."
  }

  validation {
    condition = alltrue([
      for alb in values(var.global_external_alb) :
      alltrue([for s in alb.backend_services : contains(["umig", "neg", "mig"], s.target_type)])
    ])
    error_message = "backend_services target_type must be 'umig', 'neg', or 'mig'."
  }

  validation {
    condition = alltrue(flatten([
      for alb in values(var.global_external_alb) : [
        for k in concat(
          [alb.default_service.key],
          [for d in alb.domains : d.default_service.key],
          flatten([for d in alb.domains : [for r in d.route_rules : r.service.key]])
          ) : contains(
          concat([for s in alb.backend_services : s.service_name], [for b in alb.backend_buckets : b.bucket_name]),
          k
        )
      ]
    ]))
    error_message = "Every default_service/route_rules service key must match an existing backend_services service_name or backend_buckets bucket_name in the same load balancer."
  }
}
