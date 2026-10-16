module "ecs_cluster" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/ecs-cluster?ref=v0.9.21"
  for_each = var.ecs_cluster

  name                               = each.value.name
  container_insights                 = each.value.container_insights
  execute_command_logging            = each.value.execute_command_logging
  execute_command_log_retention_days = each.value.execute_command_log_retention_days
  service_connect_namespace_arn      = try(trimspace(each.value.service_connect_namespace_arn), "") != "" ? each.value.service_connect_namespace_arn : null
  enable_fargate                     = each.value.enable_fargate
  ec2_capacity_providers             = { for cp in each.value.ec2_capacity_providers : cp.name => cp }
  default_capacity_provider_strategy = each.value.default_capacity_provider_strategy
  tags                               = each.value.tags
}
