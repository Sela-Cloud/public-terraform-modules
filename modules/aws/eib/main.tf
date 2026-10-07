################################################################################
# AWS EC2 Image Builder Resources
################################################################################

resource "aws_imagebuilder_image_recipe" "this" {
  name         = "${var.name}-recipe"
  version      = var.recipe_version
  parent_image = var.parent_image
  description  = var.description

  dynamic "component" {
    for_each = var.components
    content {
      component_arn = component.value
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-recipe"
    }
  )
}

resource "aws_imagebuilder_infrastructure_configuration" "this" {
  name                          = "${var.name}-infra-config"
  description                   = var.description
  instance_types                = var.instance_types
  instance_profile_name         = var.instance_profile_name
  subnet_id                     = var.subnet_id
  security_group_ids            = length(var.security_group_ids) > 0 ? var.security_group_ids : null
  key_pair                      = var.key_pair
  terminate_instance_on_failure = var.terminate_instance_on_failure
  sns_topic_arn                 = var.sns_topic_arn

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-infra-config"
    }
  )
}

resource "aws_imagebuilder_image_pipeline" "this" {
  name                             = "${var.name}-pipeline"
  description                      = var.description
  image_recipe_arn                 = aws_imagebuilder_image_recipe.this.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.this.arn
  status                           = var.pipeline_status

  dynamic "schedule" {
    for_each = var.schedule_expression != null ? [1] : []
    content {
      schedule_expression = var.schedule_expression
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-pipeline"
    }
  )
}
