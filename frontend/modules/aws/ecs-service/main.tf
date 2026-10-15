module "ecs_service" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/ecs-service?ref=v0.9.13"
  for_each = var.ecs_service

  name                               = each.value.name
  cluster                            = each.value.cluster
  task_definition                    = each.value.task_definition
  desired_count                      = each.value.desired_count
  launch_type                        = try(trimspace(each.value.launch_type), "") != "" ? each.value.launch_type : null
  capacity_provider_strategy         = each.value.capacity_provider_strategy
  subnet_ids                         = each.value.subnet_ids
  security_group_ids                 = each.value.security_group_ids
  assign_public_ip                   = each.value.assign_public_ip
  load_balancers                     = each.value.load_balancers
  health_check_grace_period_seconds  = each.value.health_check_grace_period_seconds
  deployment_minimum_healthy_percent = each.value.deployment_minimum_healthy_percent
  deployment_maximum_percent         = each.value.deployment_maximum_percent
  deployment_circuit_breaker         = each.value.deployment_circuit_breaker
  availability_zone_rebalancing      = each.value.availability_zone_rebalancing
  enable_execute_command             = each.value.enable_execute_command
  propagate_tags                     = each.value.propagate_tags
  force_new_deployment               = each.value.force_new_deployment
  wait_for_steady_state              = each.value.wait_for_steady_state
  service_connect = merge(each.value.service_connect, {
    namespace = try(trimspace(each.value.service_connect.namespace), "") != "" ? each.value.service_connect.namespace : null
  })
  autoscaling = each.value.autoscaling
  tags        = each.value.tags
}
