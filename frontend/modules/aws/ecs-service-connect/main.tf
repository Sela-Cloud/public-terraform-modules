module "ecs_service_connect" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/ecs-service-connect?ref=v0.9.11"
  for_each = var.ecs_service_connect

  name        = each.value.name
  description = try(trimspace(each.value.description), "") != "" ? each.value.description : null
  tags        = each.value.tags
}
