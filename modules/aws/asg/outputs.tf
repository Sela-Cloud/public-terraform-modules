output "asg_id" {
  value       = aws_autoscaling_group.asg.id
  description = "The Auto Scaling Group ID."
}

output "asg_arn" {
  value       = aws_autoscaling_group.asg.arn
  description = "The Auto Scaling Group ARN."
}

output "asg_name" {
  value       = aws_autoscaling_group.asg.name
  description = "The Auto Scaling Group name."
}

output "autoscaling_policies" {
  value = {
    for k, v in aws_autoscaling_policy.target_tracking : k => {
      arn  = v.arn
      name = v.name
    }
  }
  description = "A map of the created target tracking scaling policies and their ARNs."
}

output "scaling_schedules" {
  value = {
    for k, v in aws_autoscaling_schedule.schedule : k => {
      arn  = v.arn
      name = v.scheduled_action_name
    }
  }
  description = "A map of the created scaling schedules and their ARNs."
}
