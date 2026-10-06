################################################################################
# DB Instance Outputs
################################################################################

output "id" {
  description = "The ID of the RDS instance."
  value       = aws_db_instance.this.id
}

output "arn" {
  description = "The ARN of the RDS instance."
  value       = aws_db_instance.this.arn
}

output "endpoint" {
  description = "The connection endpoint in address:port format."
  value       = aws_db_instance.this.endpoint
}

output "db_instance_id" {
  description = "The ID of the RDS instance."
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance."
  value       = aws_db_instance.this.arn
}

output "db_instance_address" {
  description = "The hostname of the RDS instance."
  value       = aws_db_instance.this.address
}

output "db_instance_endpoint" {
  description = "The connection endpoint in address:port format."
  value       = aws_db_instance.this.endpoint
}

output "db_instance_port" {
  description = "The database port."
  value       = aws_db_instance.this.port
}

output "db_instance_name" {
  description = "The database name."
  value       = aws_db_instance.this.db_name
}

output "db_instance_username" {
  description = "The master username for the database."
  value       = aws_db_instance.this.username
  sensitive   = true
}

output "db_instance_resource_id" {
  description = "The RDS Resource ID of this instance."
  value       = aws_db_instance.this.resource_id
}

output "db_instance_status" {
  description = "The RDS instance status."
  value       = aws_db_instance.this.status
}

output "db_instance_availability_zone" {
  description = "The availability zone of the instance."
  value       = aws_db_instance.this.availability_zone
}

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)."
  value       = aws_db_instance.this.hosted_zone_id
}

output "db_master_user_secret" {
  description = "The master user secret metadata when manage_master_user_password is true."
  value       = try(aws_db_instance.this.master_user_secret, null)
}

################################################################################
# Subnet, Parameter, and Option Group Outputs
################################################################################

output "db_subnet_group_id" {
  description = "The DB subnet group name / ID."
  value       = try(aws_db_subnet_group.this[0].id, var.db_subnet_group_name)
}

output "db_subnet_group_arn" {
  description = "The ARN of the DB subnet group."
  value       = try(aws_db_subnet_group.this[0].arn, null)
}

output "db_parameter_group_id" {
  description = "The DB parameter group name / ID."
  value       = try(aws_db_parameter_group.this[0].id, var.parameter_group_name)
}

output "db_parameter_group_arn" {
  description = "The ARN of the DB parameter group."
  value       = try(aws_db_parameter_group.this[0].arn, null)
}

output "db_option_group_id" {
  description = "The DB option group name / ID."
  value       = try(aws_db_option_group.this[0].id, var.option_group_name)
}

output "db_option_group_arn" {
  description = "The ARN of the DB option group."
  value       = try(aws_db_option_group.this[0].arn, null)
}

################################################################################
# Security Group Outputs
################################################################################

output "security_group_id" {
  description = "The ID of the dedicated security group created for the database."
  value       = try(aws_security_group.this[0].id, null)
}

output "security_group_arn" {
  description = "The ARN of the dedicated security group created for the database."
  value       = try(aws_security_group.this[0].arn, null)
}

################################################################################
# Monitoring Outputs
################################################################################

output "monitoring_role_arn" {
  description = "The ARN of the IAM role used for Enhanced Monitoring."
  value       = local.monitoring_role_arn
}

output "monitoring_role_name" {
  description = "The name of the IAM role created for Enhanced Monitoring."
  value       = try(aws_iam_role.enhanced_monitoring[0].name, null)
}

################################################################################
# Role Associations & Event Subscription Outputs
################################################################################

output "role_associations" {
  description = "Map of IAM roles associated with the DB instance."
  value       = aws_db_instance_role_association.this
}

output "event_subscription_id" {
  description = "The name / ID of the DB event subscription."
  value       = try(aws_db_event_subscription.this[0].id, null)
}

output "event_subscription_arn" {
  description = "The ARN of the DB event subscription."
  value       = try(aws_db_event_subscription.this[0].arn, null)
}

