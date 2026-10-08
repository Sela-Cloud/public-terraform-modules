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

  dynamic "block_device_mapping" {
    for_each = var.block_device_mappings
    content {
      device_name = block_device_mapping.value.device_name

      dynamic "ebs" {
        for_each = block_device_mapping.value.ebs != null ? [block_device_mapping.value.ebs] : []
        content {
          volume_size = ebs.value.volume_size
          volume_type = ebs.value.volume_type
          # AWS Image Builder's own API represents these as strings, not booleans -- a provider quirk,
          # confirmed against the real resource schema, that differs from every EBS block elsewhere in
          # this catalog.
          delete_on_termination = tostring(ebs.value.delete_on_termination)
          encrypted             = ebs.value.encrypted != null ? tostring(ebs.value.encrypted) : null
          kms_key_id            = ebs.value.kms_key_id
        }
      }
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-recipe"
    }
  )

  lifecycle {
    precondition {
      condition     = length(var.components) > 0
      error_message = "At least one component is required -- AWS Image Builder rejects an image recipe with no components."
    }
  }
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

  dynamic "instance_metadata_options" {
    for_each = var.http_tokens != null ? [1] : []
    content {
      http_tokens                 = var.http_tokens
      http_put_response_hop_limit = var.http_put_response_hop_limit
    }
  }

  dynamic "logging" {
    for_each = var.logging_s3_bucket_name != null ? [1] : []
    content {
      s3_logs {
        s3_bucket_name = var.logging_s3_bucket_name
        s3_key_prefix  = var.logging_s3_key_prefix
      }
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-infra-config"
    }
  )

  lifecycle {
    precondition {
      condition     = var.instance_profile_name != null && var.instance_profile_name != ""
      error_message = "instance_profile_name is required."
    }
  }
}

resource "aws_imagebuilder_distribution_configuration" "this" {
  count = length(var.distributions) > 0 ? 1 : 0

  name = "${var.name}-distribution"

  dynamic "distribution" {
    for_each = var.distributions
    content {
      region = distribution.value.region

      dynamic "ami_distribution_configuration" {
        for_each = (
          distribution.value.ami_name != null ||
          distribution.value.ami_description != null ||
          length(distribution.value.ami_tags) > 0 ||
          distribution.value.kms_key_id != null ||
          length(distribution.value.launch_permission_account_ids) > 0
        ) ? [1] : []
        content {
          name        = distribution.value.ami_name
          description = distribution.value.ami_description
          ami_tags    = length(distribution.value.ami_tags) > 0 ? distribution.value.ami_tags : null
          kms_key_id  = distribution.value.kms_key_id

          dynamic "launch_permission" {
            for_each = length(distribution.value.launch_permission_account_ids) > 0 ? [1] : []
            content {
              user_ids = distribution.value.launch_permission_account_ids
            }
          }
        }
      }
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-distribution"
    }
  )

  lifecycle {
    precondition {
      condition     = length(distinct([for d in var.distributions : d.region])) == length(var.distributions)
      error_message = "Each distribution's region must be unique."
    }
  }
}

resource "aws_imagebuilder_image_pipeline" "this" {
  name                             = "${var.name}-pipeline"
  description                      = var.description
  image_recipe_arn                 = aws_imagebuilder_image_recipe.this.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.this.arn
  distribution_configuration_arn   = length(var.distributions) > 0 ? aws_imagebuilder_distribution_configuration.this[0].arn : null
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
