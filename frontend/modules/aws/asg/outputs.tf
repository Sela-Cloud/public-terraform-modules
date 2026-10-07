output "asg_details" {
  description = "A map of created Auto Scaling Groups and their operational attributes, keyed by hostname."
  value = {
    for k, v in module.asg : k => {
      id   = v.asg_id
      arn  = v.asg_arn
      name = v.asg_name
    }
  }
}

output "autoscaling_policies" {
  description = "A nested map containing all active target tracking policies and their generated ARNs for each environment."
  value = {
    for k, v in module.asg : k => v.autoscaling_policies
  }
}

output "scaling_schedules" {
  description = "A nested map containing all scheduled scaling policies and cron execution ARNs for each environment."
  value = {
    for k, v in module.asg : k => v.scaling_schedules
  }
}
