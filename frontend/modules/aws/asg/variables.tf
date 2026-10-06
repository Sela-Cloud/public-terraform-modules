variable "aws_region" {
  description = "The AWS Region in which the resources will be created."
  type        = string
}

variable "asg" {
  description = "The details of the AWS Auto Scaling Groups to create, keyed by hostname."
  type = map(object({
    hostname                  = string
    asg_name                  = optional(string, "")
    subnet_ids                = list(string)
    instance_template         = string
    instance_template_version = optional(string, "$Latest")

    desired_capacity = optional(number, 1)
    target_pools     = optional(list(string), []) # Target Group ARNs for ELB/ALB
    cooldown_period  = optional(number, 60)       # Map to estimated_instance_warmup

    # Instance Refresh / Rolling Update policy
    update_policy = optional(list(object({
      type                   = string # e.g., "Rolling"
      min_healthy_percentage = optional(number, 50)
      max_healthy_percentage = optional(number, 200)
      instance_warmup        = optional(number, 300)
    })), [])

    # Health check and Auto-healing
    health_check = optional(object({
      type              = optional(string, "EC2") # EC2 or ELB
      initial_delay_sec = optional(number, 30)    # Map to health_check_grace_period
    }), {})

    # Autoscaling switches & boundary sizes
    autoscaling_enabled = optional(bool, false)
    min_size            = optional(number, 1)
    max_size            = optional(number, 1)

    # Dynamic target tracking policy configuration metrics
    autoscaling_policies = optional(list(object({
      metric_name      = string # e.g. "ASGAverageCPUUtilization" or custom metric name
      target           = number # Target metric value to maintain
      is_custom_metric = optional(bool, false)
      resource_label   = optional(string, null) # Used for ALB tracking policies
      custom_metric = optional(object({
        dimension_name  = string
        dimension_value = string
        namespace       = string
        statistic       = optional(string, "Average")
      }), null)
    })), [])

    # Scheduled scaling actions
    scaling_schedules = optional(list(object({
      name                  = string
      schedule              = string # Cron expression format
      min_required_replicas = optional(number, -1)
      max_size              = optional(number, -1)
      desired_capacity      = optional(number, -1)
      time_zone             = optional(string, "UTC")
      disabled              = optional(bool, false)
    })), [])

    # Dynamic Scale-in control framework
    autoscaling_scale_in_control = optional(object({
      disabled        = optional(bool, false) # Disables scale-in capability if true
      time_window_sec = optional(number, 600)
    }), {})
  }))
  default = {}
}
