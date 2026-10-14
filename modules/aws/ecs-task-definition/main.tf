data "aws_region" "current" {}

locals {
  log_group_name = "/ecs/${var.family}"
  logging        = length([for c in var.containers : c if c.enable_logging]) > 0

  # ECS's own JSON, camelCase. Unset optionals are dropped rather than sent as null so the stored
  # definition matches what AWS returns and plans stay clean.
  container_definitions = [
    for c in var.containers : { for k, v in {
      name              = c.name
      image             = c.image
      essential         = c.essential
      cpu               = c.cpu
      memory            = c.memory
      memoryReservation = c.memory_reservation
      portMappings = [
        for p in c.port_mappings : { for pk, pv in {
          containerPort = p.container_port
          hostPort      = p.host_port
          protocol      = p.protocol
          name          = p.name
          appProtocol   = p.app_protocol
        } : pk => pv if pv != null }
      ]
      environment            = [for name in sort(keys(c.environment)) : { name = name, value = c.environment[name] }]
      secrets                = [for s in c.secrets : { name = s.name, valueFrom = s.value_from }]
      command                = length(c.command) > 0 ? c.command : null
      entryPoint             = length(c.entry_point) > 0 ? c.entry_point : null
      workingDirectory       = c.working_directory
      user                   = c.user
      readonlyRootFilesystem = c.readonly_root_filesystem
      healthCheck = c.health_check == null ? null : {
        command     = c.health_check.command
        interval    = c.health_check.interval
        timeout     = c.health_check.timeout
        retries     = c.health_check.retries
        startPeriod = c.health_check.start_period
      }
      mountPoints = [
        for m in c.mount_points : { sourceVolume = m.source_volume, containerPath = m.container_path, readOnly = m.read_only }
      ]
      dependsOn = length(c.depends_on) > 0 ? [
        for d in c.depends_on : { containerName = d.container_name, condition = d.condition }
      ] : null
      logConfiguration = c.enable_logging ? {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = local.log_group_name
          "awslogs-region"        = data.aws_region.current.region
          "awslogs-stream-prefix" = c.name
        }
      } : null
    } : k => v if v != null }
  ]
}

resource "aws_cloudwatch_log_group" "this" {
  count = local.logging ? 1 : 0

  name              = local.log_group_name
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.family
  cpu                      = var.cpu == null ? null : tostring(var.cpu)
  memory                   = var.memory == null ? null : tostring(var.memory)
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  skip_destroy             = var.skip_destroy

  container_definitions = jsonencode(local.container_definitions)

  runtime_platform {
    operating_system_family = var.operating_system_family
    cpu_architecture        = var.cpu_architecture
  }

  dynamic "ephemeral_storage" {
    for_each = var.ephemeral_storage_gib == null ? [] : [1]
    content {
      size_in_gib = var.ephemeral_storage_gib
    }
  }

  dynamic "volume" {
    for_each = var.volumes
    content {
      name = volume.value.name

      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs == null ? [] : [volume.value.efs]
        content {
          file_system_id     = efs_volume_configuration.value.file_system_id
          root_directory     = efs_volume_configuration.value.access_point_id == null ? efs_volume_configuration.value.root_directory : null
          transit_encryption = efs_volume_configuration.value.transit_encryption ? "ENABLED" : "DISABLED"

          dynamic "authorization_config" {
            for_each = efs_volume_configuration.value.access_point_id != null || efs_volume_configuration.value.iam_authorization ? [1] : []
            content {
              access_point_id = efs_volume_configuration.value.access_point_id
              iam             = efs_volume_configuration.value.iam_authorization ? "ENABLED" : "DISABLED"
            }
          }
        }
      }
    }
  }

  tags = var.tags

  # A task started before its log group exists fails to launch.
  depends_on = [aws_cloudwatch_log_group.this]

  lifecycle {
    precondition {
      condition     = !contains(var.requires_compatibilities, "FARGATE") || (var.network_mode == "awsvpc" && var.cpu != null && var.memory != null)
      error_message = "A FARGATE task definition needs network_mode 'awsvpc' and task-level cpu and memory."
    }

    precondition {
      condition     = !contains(var.requires_compatibilities, "FARGATE") || var.execution_role_arn != null || (!local.logging && length(flatten([for c in var.containers : c.secrets])) == 0)
      error_message = "A FARGATE task that logs to CloudWatch or reads secrets needs execution_role_arn: ECS uses that role to write the logs and fetch the secrets."
    }

    precondition {
      condition = alltrue(flatten([
        for c in var.containers : [for m in c.mount_points : contains([for v in var.volumes : v.name], m.source_volume)]
      ]))
      error_message = "Every container mount_points source_volume must name one of the task's volumes."
    }

    precondition {
      condition = alltrue(flatten([
        for c in var.containers : [for d in c.depends_on : contains([for o in var.containers : o.name if o.name != c.name], d.container_name)]
      ]))
      error_message = "Every container depends_on container_name must name another container in this task."
    }
  }
}
