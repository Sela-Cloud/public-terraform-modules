variable "hostname" {
  type        = string
  description = "Base name for instances and resources"
}

variable "asg_name" {
  type    = string
  default = ""
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets where the instances will deploy"
}

variable "instance_template" {
  type        = string
  description = "The ID of the EC2 Launch Template"
}

variable "instance_template_version" {
  type    = string
  default = "$Latest"
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 5
}

variable "cooldown_period" {
  type    = number
  default = 300
}

variable "autoscaling_enabled" {
  type    = bool
  default = true
}

variable "health_check" {
  type = map(any)
  default = {
    type              = "EC2"
    initial_delay_sec = 300
  }
}

variable "target_pools" {
  type        = list(string)
  default     = []
  description = "ARNs of target groups to attach to the ASG"
}

variable "update_policy" {
  type    = list(any)
  default = []
}

variable "autoscaling_scale_in_control" {
  type = object({
    disabled        = bool
    time_window_sec = number
  })
  default = {
    disabled        = false
    time_window_sec = 600
  }
}

# The block allowing arbitrary metric combinations (CPU, Traffic, Memory, etc.)
variable "autoscaling_policies" {
  type        = list(any)
  default     = []
  description = "List of maps containing scaling target tracking configs"
}

variable "scaling_schedules" {
  type    = list(any)
  default = []
}
