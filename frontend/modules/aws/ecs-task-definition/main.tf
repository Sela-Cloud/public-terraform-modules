module "ecs_task_definition" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/ecs-task-definition?ref=v0.9.20"
  for_each = var.ecs_task_definition

  family                   = each.value.family
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  network_mode             = each.value.network_mode
  requires_compatibilities = each.value.requires_compatibilities
  execution_role_arn       = try(trimspace(each.value.execution_role_arn), "") != "" ? each.value.execution_role_arn : null
  task_role_arn            = try(trimspace(each.value.task_role_arn), "") != "" ? each.value.task_role_arn : null
  operating_system_family  = each.value.operating_system_family
  cpu_architecture         = each.value.cpu_architecture
  ephemeral_storage_gib    = each.value.ephemeral_storage_gib
  log_retention_days       = each.value.log_retention_days
  skip_destroy             = each.value.skip_destroy
  volumes                  = each.value.volumes
  containers               = each.value.containers
  tags                     = each.value.tags
}
