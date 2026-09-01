variable "project_id" {
  description = "Project where the load balancer frontend (address, url map, proxy, forwarding rule) is created."
  type        = string
}

variable "backend_project_id" {
  description = "Project where backend resources (instance groups, NEGs, buckets) live. Defaults to project_id when not using Shared VPC."
  type        = string
  default     = null
}

variable "name" {
  description = "Base name used to derive resource names (address, url map, proxy, forwarding rule)."
  type        = string
}

variable "existing_static_ip_name" {
  description = "Name of an existing google_compute_global_address to reuse. Leave unset to create a new one."
  type        = string
  default     = null
}

variable "certificate_map_name" {
  description = "Name of an existing Certificate Manager certificate map used for TLS termination."
  type        = string
}

variable "default_service" {
  description = "The url map's default backend. type is 'service' or 'bucket'; key must match a key in backend_services or backend_buckets."
  type = object({
    type = string
    key  = string
  })
}

variable "create_http_redirect" {
  description = "Whether to create an HTTP (port 80) listener that redirects to HTTPS."
  type        = bool
  default     = true
}

variable "backend_buckets" {
  description = "GCS-backed backends, keyed by bucket_name."
  type = map(object({
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
        include_http_headers   = optional(list(string))
        query_string_whitelist = optional(list(string))
      }), {})
    }))
  }))
  default = {}
}

variable "backend_services" {
  description = "HTTP(S) backends, keyed by service_name. target_type selects umig, neg, or mig fields."
  type = map(object({
    service_name = string
    target_type  = string # "umig", "neg", or "mig"

    umig_name = optional(string)
    umig_zone = optional(string)

    neg_name   = optional(string)
    neg_region = optional(string)

    mig_name   = optional(string)
    mig_region = optional(string)

    port_name = optional(string, "http")

    enable_health_check = optional(bool, false)
    health_check_port   = optional(number, 80)

    enable_cdn = optional(bool, false)
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
        query_string_blacklist = optional(list(string))
        query_string_whitelist = optional(list(string))
        include_http_headers   = optional(list(string))
        include_named_cookies  = optional(list(string))
      }), {})
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for svc in values(var.backend_services) : contains(["umig", "neg", "mig"], svc.target_type)
    ])
    error_message = "backend_services target_type must be 'umig', 'neg', or 'mig'."
  }

  validation {
    condition = alltrue([
      for svc in values(var.backend_services) :
      svc.target_type != "umig" || (try(trimspace(svc.umig_name), "") != "" && try(trimspace(svc.umig_zone), "") != "")
    ])
    error_message = "backend_services with target_type 'umig' require umig_name and umig_zone."
  }

  validation {
    condition = alltrue([
      for svc in values(var.backend_services) :
      svc.target_type != "neg" || (try(trimspace(svc.neg_name), "") != "" && try(trimspace(svc.neg_region), "") != "")
    ])
    error_message = "backend_services with target_type 'neg' require neg_name and neg_region."
  }

  validation {
    condition = alltrue([
      for svc in values(var.backend_services) :
      svc.target_type != "mig" || (try(trimspace(svc.mig_name), "") != "" && try(trimspace(svc.mig_region), "") != "")
    ])
    error_message = "backend_services with target_type 'mig' require mig_name and mig_region."
  }
}

variable "domains" {
  description = "Host-based routing rules, keyed by a matcher key. Each domain's default_service/route_rules[].service key must reference a backend_services or backend_buckets key."
  type = map(object({
    hosts = list(string)
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
  }))
  default = {}
}
