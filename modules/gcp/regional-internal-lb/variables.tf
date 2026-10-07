variable "project_id" {
  description = "Project where the load balancer frontend (address, url map, proxy, forwarding rule) is created."
  type        = string
}

variable "backend_project_id" {
  description = "Project where backend resources (backend services, instance groups, NEGs, health checks) live. Defaults to project_id when not using Shared VPC."
  type        = string
  default     = null
}

variable "name" {
  description = "Base name used to derive resource names (address, url map, proxy, forwarding rule)."
  type        = string
}

variable "region" {
  description = "Region the load balancer serves in. Every backend must live in this region."
  type        = string
}

variable "network" {
  description = "VPC network the load balancer's address belongs to: a name in project_id, or a self link / projects/... path for a Shared VPC host network. The network needs a proxy-only subnet (purpose REGIONAL_MANAGED_PROXY) in this region."
  type        = string
}

variable "subnetwork" {
  description = "Subnet the load balancer's internal IP is taken from: a name in project_id and region, or a self link / projects/... path for a Shared VPC subnet. Must not be the proxy-only subnet."
  type        = string
}

variable "existing_address_name" {
  description = "Name of an existing regional internal address (in project_id and region) to reuse. Leave unset to reserve a new one."
  type        = string
  default     = null
}

variable "address" {
  description = "Specific internal IP to reserve from the subnet when creating a new address. Leave unset to let Google pick one. Ignored when existing_address_name is set."
  type        = string
  default     = null
}

variable "certificate_names" {
  description = "Regional Certificate Manager certificates presented by the HTTPS proxy, in region. Each entry is a certificate name in project_id or a full projects/{p}/locations/{region}/certificates/{name} path."
  type        = list(string)

  validation {
    condition     = length(var.certificate_names) >= 1 && alltrue([for c in var.certificate_names : trimspace(c) != ""])
    error_message = "certificate_names needs at least one non-empty certificate name."
  }
}

variable "create_http_redirect" {
  description = "Whether to also listen on port 80 and redirect to HTTPS, on the same IP."
  type        = bool
  default     = false
}

variable "allow_global_access" {
  description = "Whether clients in other regions of the VPC (or connected networks) may reach the load balancer. Off keeps it reachable from its own region only."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels applied to the address and forwarding rules."
  type        = map(string)
  default     = {}
}

variable "default_service" {
  description = "Key of the backend_services entry the url map sends traffic to when no domain matches."
  type        = string
}

variable "backend_services" {
  description = "HTTP backends, keyed by service_name. target_type selects umig, mig, neg, or cloud_run fields. All backends are in var.region."
  type = map(object({
    service_name = string
    target_type  = string # "umig", "mig", "neg", or "cloud_run"

    umig_name = optional(string)
    # A zone of var.region, such as us-central1-a.
    umig_zone = optional(string)

    # A regional managed instance group in var.region.
    mig_name = optional(string)

    # An existing regional network endpoint group in var.region, created and owned elsewhere.
    neg_name = optional(string)

    # A Cloud Run backend names the service directly; this module builds the serverless NEG
    # that fronts it, because such a NEG exists only to attach one service to one load
    # balancer and has no lifecycle of its own.
    cloud_run_service = optional(string)

    port_name = optional(string, "http")

    # How long the load balancer waits for a backend's complete response, first request byte to
    # last response byte. Not the health check's timeout.
    timeout_sec = optional(number, 30)

    enable_health_check = optional(bool, false)
    health_check_type   = optional(string, "tcp")
    health_check_port   = optional(number, 80)
    # HTTP only; ignored by a TCP check.
    health_check_request_path = optional(string, "/")
    # Timing, in the provider's own defaults. The timeout may not exceed the interval — see the
    # validation below.
    health_check_interval_sec        = optional(number, 5)
    health_check_timeout_sec         = optional(number, 5)
    health_check_healthy_threshold   = optional(number, 2)
    health_check_unhealthy_threshold = optional(number, 2)
  }))
  default = {}

  validation {
    condition = alltrue([
      for svc in values(var.backend_services) : contains(["umig", "mig", "neg", "cloud_run"], svc.target_type)
    ])
    error_message = "backend_services target_type must be 'umig', 'mig', 'neg', or 'cloud_run'."
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
      svc.target_type != "mig" || try(trimspace(svc.mig_name), "") != ""
    ])
    error_message = "backend_services with target_type 'mig' require mig_name."
  }

  validation {
    condition = alltrue([
      for svc in values(var.backend_services) :
      svc.target_type != "neg" || try(trimspace(svc.neg_name), "") != ""
    ])
    error_message = "backend_services with target_type 'neg' require neg_name."
  }

  validation {
    condition = alltrue([
      for svc in values(var.backend_services) :
      svc.target_type != "cloud_run" || try(trimspace(svc.cloud_run_service), "") != ""
    ])
    error_message = "backend_services with target_type 'cloud_run' require cloud_run_service."
  }

  validation {
    condition = alltrue([
      for svc in values(var.backend_services) : contains(["tcp", "http"], svc.health_check_type)
    ])
    error_message = "backend_services health_check_type must be 'tcp' or 'http'."
  }

  validation {
    condition = alltrue([
      for svc in values(var.backend_services) :
      svc.timeout_sec >= 1 && svc.timeout_sec <= 2147483647 && floor(svc.timeout_sec) == svc.timeout_sec
    ])
    error_message = "backend_services timeout_sec must be a whole number of seconds from 1 to 2147483647."
  }

  # The API rejects a timeout longer than the interval, but only at apply time and without naming
  # the backend.
  validation {
    condition = alltrue([
      for svc in values(var.backend_services) :
      !svc.enable_health_check || svc.health_check_timeout_sec <= svc.health_check_interval_sec
    ])
    error_message = "backend_services health_check_timeout_sec cannot exceed health_check_interval_sec — a probe cannot wait longer than the gap before the next one. Lower the timeout along with the interval."
  }

  validation {
    condition = alltrue([
      for svc in values(var.backend_services) :
      !svc.enable_health_check || (
        svc.health_check_interval_sec >= 1 && svc.health_check_timeout_sec >= 1 &&
        svc.health_check_healthy_threshold >= 1 && svc.health_check_unhealthy_threshold >= 1
      )
    ])
    error_message = "backend_services health check interval, timeout and thresholds must each be at least 1."
  }

  validation {
    condition = alltrue([
      for svc in values(var.backend_services) : svc.target_type != "cloud_run" || !svc.enable_health_check
    ])
    error_message = "backend_services with target_type 'cloud_run' cannot use a health check: Google Cloud does not support health checks on serverless NEG backends."
  }
}

variable "domains" {
  description = "Host-based routing rules, keyed by a matcher key. Each domain's default_service and route_rules[].service must be a backend_services key."
  type = map(object({
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
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for d in values(var.domains) : [
        for r in d.route_rules :
        r.match_mode == null || contains(["PREFIX_MATCH", "PATH_TEMPLATE_MATCH", "FULL_PATH_MATCH", "REGEX_MATCH"], r.match_mode)
      ]
    ]))
    error_message = "route_rules match_mode must be PREFIX_MATCH, PATH_TEMPLATE_MATCH, FULL_PATH_MATCH or REGEX_MATCH."
  }
}
