################################################################################
# Application Load Balancer Outputs
################################################################################

output "id" {
  description = "The ARN of the Application Load Balancer."
  value       = aws_lb.this.id
}

output "arn" {
  description = "The ARN of the Application Load Balancer."
  value       = aws_lb.this.arn
}

output "arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics."
  value       = aws_lb.this.arn_suffix
}

output "dns_name" {
  description = "The DNS name of the Application Load Balancer."
  value       = aws_lb.this.dns_name
}

output "zone_id" {
  description = "The canonical hosted zone ID of the Application Load Balancer (to be used when creating a Route 53 Alias record)."
  value       = aws_lb.this.zone_id
}

output "name" {
  description = "The name of the Application Load Balancer."
  value       = aws_lb.this.name
}

output "security_group_id" {
  description = "The ID of the dedicated Security Group created for the ALB, if enabled."
  value       = try(aws_security_group.this[0].id, null)
}

output "target_groups" {
  description = "Map of created target groups and their attributes."
  value = {
    for k, tg in aws_lb_target_group.this : k => {
      id         = tg.id
      arn        = tg.arn
      arn_suffix = tg.arn_suffix
      name       = tg.name
    }
  }
}

output "target_group_arns" {
  description = "List of ARNs of all created target groups."
  value       = [for tg in aws_lb_target_group.this : tg.arn]
}

output "listeners" {
  description = "Map of created listeners and their attributes."
  value = {
    for k, l in aws_lb_listener.this : k => {
      id       = l.id
      arn      = l.arn
      port     = l.port
      protocol = l.protocol
    }
  }
}

output "listener_rules" {
  description = "Map of created listener rules and their attributes."
  value = {
    for k, r in aws_lb_listener_rule.this : k => {
      id  = r.id
      arn = r.arn
    }
  }
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags."
  value       = aws_lb.this.tags_all
}
