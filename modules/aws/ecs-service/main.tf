locals {
  # Autoscaling addresses the service as service/<cluster name>/<service name>; the cluster may have
  # been given as an ARN, whose last path segment is the name.
  cluster_name = element(split("/", var.cluster), length(split("/", var.cluster)) - 1)
}

resource "aws_ecs_service" "this" {
  name            = var.name
  cluster         = var.cluster
  task_definition = var.task_definition
  desired_count   = var.desired_count

  launch_type = length(var.capacity_provider_strategy) == 0 ? var.launch_type : null

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
      base              = capacity_provider_strategy.value.base
    }
  }

  dynamic "network_configuration" {
    for_each = length(var.subnet_ids) > 0 ? [1] : []
    content {
      subnets          = var.subnet_ids
      security_groups  = var.security_group_ids
      assign_public_ip = var.assign_public_ip
    }
  }

  dynamic "load_balancer" {
    for_each = var.load_balancers
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  health_check_grace_period_seconds = length(var.load_balancers) > 0 ? var.health_check_grace_period_seconds : null

  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  availability_zone_rebalancing      = var.availability_zone_rebalancing

  deployment_circuit_breaker {
    enable   = var.deployment_circuit_breaker.enable
    rollback = var.deployment_circuit_breaker.rollback
  }

  # Service Connect is a property of the service, not a resource of its own; the namespace it joins
  # is the ecs-service-connect module's.
  dynamic "service_connect_configuration" {
    for_each = var.service_connect.enabled ? [1] : []
    content {
      enabled   = true
      namespace = var.service_connect.namespace

      dynamic "service" {
        for_each = var.service_connect.services
        content {
          port_name      = service.value.port_name
          discovery_name = service.value.discovery_name

          client_alias {
            port     = service.value.client_alias_port
            dns_name = service.value.client_alias_dns_name
          }
        }
      }
    }
  }

  enable_execute_command  = var.enable_execute_command
  propagate_tags          = var.propagate_tags
  enable_ecs_managed_tags = true
  force_new_deployment    = var.force_new_deployment
  wait_for_steady_state   = var.wait_for_steady_state

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.launch_type == null || length(var.capacity_provider_strategy) == 0
      error_message = "Set launch_type or capacity_provider_strategy, not both."
    }

    precondition {
      condition     = var.availability_zone_rebalancing == "DISABLED" || var.deployment_maximum_percent > 100
      error_message = "availability_zone_rebalancing ENABLED needs deployment_maximum_percent above 100, so ECS has room to start a replacement task before stopping one."
    }

    precondition {
      condition     = var.deployment_minimum_healthy_percent >= 0 && var.deployment_minimum_healthy_percent <= var.deployment_maximum_percent
      error_message = "deployment_minimum_healthy_percent must be between 0 and deployment_maximum_percent."
    }
  }
}

resource "aws_appautoscaling_target" "this" {
  count = var.autoscaling.enabled ? 1 : 0

  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
  resource_id        = "service/${local.cluster_name}/${aws_ecs_service.this.name}"
  min_capacity       = var.autoscaling.min_capacity
  max_capacity       = var.autoscaling.max_capacity
  tags               = var.tags
}

resource "aws_appautoscaling_policy" "this" {
  for_each = var.autoscaling.enabled ? { for p in var.autoscaling.policies : p.name => p } : {}

  name               = "${var.name}-${each.key}"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  resource_id        = aws_appautoscaling_target.this[0].resource_id

  target_tracking_scaling_policy_configuration {
    target_value       = each.value.target_value
    scale_in_cooldown  = each.value.scale_in_cooldown
    scale_out_cooldown = each.value.scale_out_cooldown
    disable_scale_in   = each.value.disable_scale_in

    predefined_metric_specification {
      predefined_metric_type = each.value.metric
      resource_label         = each.value.metric == "ALBRequestCountPerTarget" ? each.value.resource_label : null
    }
  }
}
