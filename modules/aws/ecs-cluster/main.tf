locals {
  exec_log_group_name = "/ecs/${var.name}/exec"

  capacity_providers = concat(
    var.enable_fargate ? ["FARGATE", "FARGATE_SPOT"] : [],
    [for cp in aws_ecs_capacity_provider.ec2 : cp.name],
  )
}

resource "aws_cloudwatch_log_group" "exec" {
  count = var.execute_command_logging == "OVERRIDE" ? 1 : 0

  name              = local.exec_log_group_name
  retention_in_days = var.execute_command_log_retention_days
  tags              = var.tags
}

resource "aws_ecs_cluster" "this" {
  name = var.name

  setting {
    name  = "containerInsights"
    value = var.container_insights
  }

  configuration {
    execute_command_configuration {
      logging = var.execute_command_logging

      dynamic "log_configuration" {
        for_each = var.execute_command_logging == "OVERRIDE" ? [1] : []
        content {
          cloud_watch_log_group_name = aws_cloudwatch_log_group.exec[0].name
        }
      }
    }
  }

  dynamic "service_connect_defaults" {
    for_each = var.service_connect_namespace_arn == null ? [] : [1]
    content {
      namespace = var.service_connect_namespace_arn
    }
  }

  tags = var.tags

  lifecycle {
    # Cross-variable checks need Terraform 1.9 as validations; a precondition gives the same named
    # error before anything is sent to AWS. It sits on the cluster, which always exists, so it also
    # fires when no capacity provider is registered at all.
    precondition {
      condition = alltrue([
        for s in var.default_capacity_provider_strategy :
        contains(concat(var.enable_fargate ? ["FARGATE", "FARGATE_SPOT"] : [], [for cp in values(var.ec2_capacity_providers) : cp.name]), s.capacity_provider)
      ])
      error_message = "Every default_capacity_provider_strategy entry must name FARGATE or FARGATE_SPOT (with enable_fargate on) or one of this cluster's ec2_capacity_providers."
    }
  }
}

# An EC2 capacity provider is the cluster's handle on an ASG the catalog's asg module (or anything
# else) already owns. It belongs to this cluster alone, so it lives and dies with the cluster.
resource "aws_ecs_capacity_provider" "ec2" {
  for_each = var.ec2_capacity_providers

  name = each.value.name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = each.value.auto_scaling_group_arn
    managed_termination_protection = each.value.managed_termination_protection ? "ENABLED" : "DISABLED"
    managed_draining               = each.value.managed_draining ? "ENABLED" : "DISABLED"

    managed_scaling {
      status          = each.value.managed_scaling ? "ENABLED" : "DISABLED"
      target_capacity = each.value.target_capacity
    }
  }

  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  count = length(local.capacity_providers) > 0 ? 1 : 0

  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = local.capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy
    content {
      capacity_provider = default_capacity_provider_strategy.value.capacity_provider
      weight            = default_capacity_provider_strategy.value.weight
      base              = default_capacity_provider_strategy.value.base
    }
  }
}
