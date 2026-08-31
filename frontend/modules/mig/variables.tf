variable "project_id" {
  description = "The GCP Project ID in which the managed instance group is created."
  type        = string
}

variable "mig" {
  description = "The details of the regional Managed Instance Groups to create, keyed by hostname."
  type = map(object({
    hostname          = string
    mig_name          = optional(string, "")
    region            = string
    instance_template = string

    target_size               = optional(number, 1)
    target_pools              = optional(list(string), [])
    distribution_policy_zones = optional(list(string), [])
    wait_for_instances        = optional(bool, false)
    named_ports = optional(list(object({
      name = string
      port = number
    })), [])
    mig_timeouts = optional(object({
      create = optional(string, "5m")
      update = optional(string, "5m")
      delete = optional(string, "15m")
    }), {})

    # Stateful configuration
    stateful_disks = optional(list(object({
      device_name = string
      delete_rule = optional(string, "NEVER")
    })), [])
    stateful_ips = optional(list(object({
      interface_name = string
      delete_rule    = optional(string, "NEVER")
      is_external    = optional(bool, false)
    })), [])

    # Rolling update. The remote module's object type declares exactly these five
    # attributes, so anything else added here would be silently dropped on conversion.
    update_policy = optional(list(object({
      minimal_action     = string
      type               = string
      max_surge_fixed    = optional(number, 0)
      min_ready_sec      = optional(number, 0)
      replacement_method = optional(string, "RECREATE")
    })), [{ minimal_action = "REPLACE", type = "PROACTIVE" }])

    lifecycle_policy = optional(object({
      force_update_on_repair = optional(string, "YES")
    }), {})

    # Health check and auto-healing
    health_check_name = optional(string, "")
    health_check = optional(object({
      type                = optional(string, "tcp")
      initial_delay_sec   = optional(number, 30)
      check_interval_sec  = optional(number, 30)
      healthy_threshold   = optional(number, 1)
      timeout_sec         = optional(number, 10)
      unhealthy_threshold = optional(number, 5)
      response            = optional(string, "")
      proxy_header        = optional(string, "NONE")
      port                = optional(number, 80)
      request             = optional(string, "")
      request_path        = optional(string, "/")
      host                = optional(string, "")
      enable_logging      = optional(bool, true)
    }), {})

    # Autoscaling
    autoscaling_enabled = optional(bool, false)
    autoscaler_name     = optional(string, "")
    min_replicas        = optional(number, 1)
    max_replicas        = optional(number, 1)
    cooldown_period     = optional(number, 60)
    autoscaling_mode    = optional(string, null)
    autoscaling_cpu = optional(list(object({
      target            = number
      predictive_method = optional(string, "NONE")
    })), [])
    autoscaling_lb = optional(list(object({
      target = number
    })), [])
    autoscaling_metric = optional(list(object({
      name   = string
      target = number
      type   = string
    })), [])
    scaling_schedules = optional(list(object({
      name                  = string
      schedule              = string
      duration_sec          = number
      min_required_replicas = number
      time_zone             = optional(string, "UTC")
      disabled              = optional(bool, false)
    })), [])
    autoscaling_scale_in_control = optional(object({
      fixed_replicas   = optional(number, null)
      percent_replicas = optional(number, null)
      time_window_sec  = optional(number, null)
    }), {})
  }))
  default = {}
}
