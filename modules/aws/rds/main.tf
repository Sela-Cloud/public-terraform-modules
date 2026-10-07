locals {
  is_postgres = lower(var.engine) == "postgres"
  is_mysql    = contains(["mysql", "mariadb"], lower(var.engine))

  # Normalized identifier for resource naming
  identifier = coalesce(var.identifier, var.identifier_prefix, "rds")

  # Default DB port based on engine
  default_port = local.is_postgres ? 5432 : 3306
  port         = coalesce(var.port, local.default_port)

  # Default DB parameter group family based on engine
  default_family = local.is_postgres ? "postgres16" : "mysql8.0"
  family         = coalesce(var.family, local.default_family)

  # Default major engine version for option group (if used)
  default_major_engine_version = local.is_postgres ? "16" : "8.0"
  major_engine_version         = coalesce(var.major_engine_version, local.default_major_engine_version)

  # Resolution of Subnet, Parameter, and Option Group names
  db_subnet_group_name = var.create_db_subnet_group ? try(aws_db_subnet_group.this[0].name, null) : var.db_subnet_group_name
  parameter_group_name = var.create_db_parameter_group ? try(aws_db_parameter_group.this[0].name, null) : var.parameter_group_name
  option_group_name    = var.create_db_option_group ? try(aws_db_option_group.this[0].name, null) : var.option_group_name

  # Enhanced Monitoring IAM role resolution
  monitoring_role_arn = var.monitoring_interval > 0 ? (
    var.create_monitoring_role ? try(aws_iam_role.enhanced_monitoring[0].arn, null) : var.monitoring_role_arn
  ) : null

  # Consolidated Security Group IDs
  security_group_ids = compact(concat(
    var.vpc_security_group_ids,
    try([aws_security_group.this[0].id], [])
  ))

  # Final snapshot identifier calculation
  final_snapshot_identifier = var.skip_final_snapshot ? null : coalesce(
    var.final_snapshot_identifier,
    "${local.identifier}-final-snapshot"
  )

  # Master username resolution
  username = var.replicate_source_db == null && var.snapshot_identifier == null ? coalesce(
    var.username,
    local.is_postgres ? "postgres" : "admin"
  ) : null

  # Master password / AWS Secrets Manager management
  manage_master_user_password = var.replicate_source_db == null && var.snapshot_identifier == null && var.manage_master_user_password ? true : null
  password                    = var.replicate_source_db == null && var.snapshot_identifier == null && !var.manage_master_user_password ? var.password : null
}

################################################################################
# DB Subnet Group
################################################################################

resource "aws_db_subnet_group" "this" {
  count       = var.create_db_subnet_group ? 1 : 0
  name        = var.db_subnet_group_use_name_prefix ? null : coalesce(var.db_subnet_group_name, "${local.identifier}-subnet-group")
  name_prefix = var.db_subnet_group_use_name_prefix ? coalesce(var.db_subnet_group_name, "${local.identifier}-") : null
  description = coalesce(var.db_subnet_group_description, "Database subnet group for ${local.identifier}")
  subnet_ids  = var.subnet_ids

  tags = merge(
    var.tags,
    var.db_subnet_group_tags,
    {
      Name = coalesce(var.db_subnet_group_name, "${local.identifier}-subnet-group")
    }
  )
}

################################################################################
# DB Parameter Group
################################################################################

resource "aws_db_parameter_group" "this" {
  count       = var.create_db_parameter_group ? 1 : 0
  name        = var.parameter_group_use_name_prefix ? null : coalesce(var.parameter_group_name, "${local.identifier}-pg")
  name_prefix = var.parameter_group_use_name_prefix ? coalesce(var.parameter_group_name, "${local.identifier}-") : null
  family      = local.family
  description = coalesce(var.parameter_group_description, "Database parameter group for ${local.identifier}")

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = try(parameter.value.apply_method, null)
    }
  }

  tags = merge(
    var.tags,
    var.parameter_group_tags,
    {
      Name = coalesce(var.parameter_group_name, "${local.identifier}-pg")
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# DB Option Group
################################################################################

resource "aws_db_option_group" "this" {
  count                    = var.create_db_option_group ? 1 : 0
  name                     = var.option_group_use_name_prefix ? null : coalesce(var.option_group_name, "${local.identifier}-og")
  name_prefix              = var.option_group_use_name_prefix ? coalesce(var.option_group_name, "${local.identifier}-") : null
  engine_name              = var.engine
  major_engine_version     = local.major_engine_version
  option_group_description = coalesce(var.option_group_description, "Database option group for ${local.identifier}")

  dynamic "option" {
    for_each = var.options
    content {
      option_name                    = option.value.option_name
      port                           = try(option.value.port, null)
      version                        = try(option.value.version, null)
      db_security_group_memberships  = try(option.value.db_security_group_memberships, null)
      vpc_security_group_memberships = try(option.value.vpc_security_group_memberships, null)

      dynamic "option_settings" {
        for_each = try(option.value.option_settings, [])
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }

  tags = merge(
    var.tags,
    var.option_group_tags,
    {
      Name = coalesce(var.option_group_name, "${local.identifier}-og")
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Dedicated Security Group for RDS
################################################################################

resource "aws_security_group" "this" {
  count       = var.create_security_group && var.vpc_id != null ? 1 : 0
  name        = var.security_group_use_name_prefix ? null : coalesce(var.security_group_name, "${local.identifier}-sg")
  name_prefix = var.security_group_use_name_prefix ? coalesce(var.security_group_name, "${local.identifier}-") : null
  description = coalesce(var.security_group_description, "Security group for RDS ${local.identifier} database")
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    var.security_group_tags,
    {
      Name = coalesce(var.security_group_name, "${local.identifier}-sg")
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "cidr" {
  for_each = var.create_security_group && var.vpc_id != null && length(var.allowed_cidr_blocks) > 0 ? toset(var.allowed_cidr_blocks) : []

  security_group_id = aws_security_group.this[0].id
  description       = "Allow inbound database traffic from IPv4 CIDR"
  ip_protocol       = "tcp"
  from_port         = local.port
  to_port           = local.port
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "ipv6_cidr" {
  for_each = var.create_security_group && var.vpc_id != null && length(var.allowed_ipv6_cidr_blocks) > 0 ? toset(var.allowed_ipv6_cidr_blocks) : []

  security_group_id = aws_security_group.this[0].id
  description       = "Allow inbound database traffic from IPv6 CIDR"
  ip_protocol       = "tcp"
  from_port         = local.port
  to_port           = local.port
  cidr_ipv6         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "security_groups" {
  for_each = var.create_security_group && var.vpc_id != null && length(var.allowed_security_group_ids) > 0 ? toset(var.allowed_security_group_ids) : []

  security_group_id            = aws_security_group.this[0].id
  description                  = "Allow inbound database traffic from source security group"
  ip_protocol                  = "tcp"
  from_port                    = local.port
  to_port                      = local.port
  referenced_security_group_id = each.value
}

resource "aws_vpc_security_group_egress_rule" "all" {
  count = var.create_security_group && var.vpc_id != null ? 1 : 0

  security_group_id = aws_security_group.this[0].id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

################################################################################
# Enhanced Monitoring IAM Role
################################################################################

resource "aws_iam_role" "enhanced_monitoring" {
  count = var.create_monitoring_role && var.monitoring_interval > 0 ? 1 : 0
  name  = coalesce(var.monitoring_role_name, "${local.identifier}-rds-monitoring-role")

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    var.monitoring_role_tags,
    {
      Name = coalesce(var.monitoring_role_name, "${local.identifier}-rds-monitoring-role")
    }
  )
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  count      = var.create_monitoring_role && var.monitoring_interval > 0 ? 1 : 0
  role       = aws_iam_role.enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

################################################################################
# AWS RDS DB Instance
################################################################################

resource "aws_db_instance" "this" {
  identifier        = var.identifier_prefix != null ? null : var.identifier
  identifier_prefix = var.identifier_prefix

  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  max_allocated_storage = (
    var.max_allocated_storage != null && var.max_allocated_storage > var.allocated_storage ?
    var.max_allocated_storage : null
  )
  storage_type         = var.storage_type
  iops                 = contains(["gp3", "io1", "io2"], var.storage_type) ? var.iops : null
  storage_throughput   = var.storage_type == "gp3" ? var.storage_throughput : null
  dedicated_log_volume = var.dedicated_log_volume
  storage_encrypted    = var.storage_encrypted
  kms_key_id           = var.storage_encrypted ? var.kms_key_id : null
  license_model        = var.license_model
  character_set_name   = var.character_set_name

  db_name                       = var.replicate_source_db == null ? var.db_name : null
  username                      = local.username
  password                      = local.password
  manage_master_user_password   = local.manage_master_user_password
  master_user_secret_kms_key_id = local.manage_master_user_password != null ? var.master_user_secret_kms_key_id : null
  port                          = local.port

  multi_az               = var.multi_az
  availability_zone      = var.multi_az ? null : var.availability_zone
  publicly_accessible    = var.publicly_accessible
  network_type           = var.network_type
  ca_cert_identifier     = var.ca_cert_identifier
  vpc_security_group_ids = length(local.security_group_ids) > 0 ? local.security_group_ids : null
  db_subnet_group_name   = local.db_subnet_group_name
  parameter_group_name   = local.parameter_group_name
  option_group_name      = local.option_group_name

  backup_retention_period   = var.replicate_source_db != null ? null : var.backup_retention_period
  backup_window             = var.backup_window
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = local.final_snapshot_identifier
  maintenance_window        = var.maintenance_window

  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = var.apply_immediately
  deletion_protection         = var.deletion_protection
  delete_automated_backups    = var.delete_automated_backups

  enabled_cloudwatch_logs_exports = length(var.enabled_cloudwatch_logs_exports) > 0 ? var.enabled_cloudwatch_logs_exports : null

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = local.monitoring_role_arn

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  snapshot_identifier         = var.snapshot_identifier
  replicate_source_db         = var.replicate_source_db
  domain                      = var.domain
  domain_iam_role_name        = var.domain_iam_role_name
  domain_auth_secret_arn      = var.domain_auth_secret_arn
  domain_dns_ips              = var.domain_dns_ips
  custom_iam_instance_profile = var.custom_iam_instance_profile

  dynamic "blue_green_update" {
    for_each = var.blue_green_update != null ? [var.blue_green_update] : []
    content {
      enabled = try(blue_green_update.value.enabled, false)
    }
  }

  dynamic "restore_to_point_in_time" {
    for_each = var.restore_to_point_in_time != null ? [var.restore_to_point_in_time] : []
    content {
      restore_time                             = try(restore_to_point_in_time.value.restore_time, null)
      source_db_instance_automated_backups_arn = try(restore_to_point_in_time.value.source_db_instance_automated_backups_arn, null)
      source_db_instance_identifier            = try(restore_to_point_in_time.value.source_db_instance_identifier, null)
      source_dbi_resource_id                   = try(restore_to_point_in_time.value.source_dbi_resource_id, null)
      use_latest_restorable_time               = try(restore_to_point_in_time.value.use_latest_restorable_time, null)
    }
  }

  dynamic "s3_import" {
    for_each = var.s3_import != null ? [var.s3_import] : []
    content {
      bucket_name           = s3_import.value.bucket_name
      bucket_prefix         = try(s3_import.value.bucket_prefix, null)
      ingestion_role        = s3_import.value.ingestion_role
      source_engine         = s3_import.value.source_engine
      source_engine_version = s3_import.value.source_engine_version
    }
  }

  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }

  tags = merge(
    var.tags,
    {
      Name = local.identifier
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.enhanced_monitoring
  ]

  lifecycle {
    precondition {
      condition     = var.manage_master_user_password || var.replicate_source_db != null || var.snapshot_identifier != null || (var.password != null && var.password != "")
      error_message = "password is required when manage_master_user_password is false and not restoring from a snapshot or replica."
    }
    precondition {
      condition     = !var.create_security_group || var.vpc_id != null
      error_message = "vpc_id is required when create_security_group is true."
    }
    precondition {
      condition     = !var.create_db_subnet_group || length(var.subnet_ids) >= 2
      error_message = "subnet_ids must include at least 2 subnets (in different AZs) when create_db_subnet_group is true."
    }
  }
}

################################################################################
# DB Instance IAM Role Associations
################################################################################

resource "aws_db_instance_role_association" "this" {
  for_each = var.role_associations

  db_instance_identifier = aws_db_instance.this.identifier
  feature_name           = each.value.feature_name
  role_arn               = each.value.role_arn
}

################################################################################
# DB Event Subscription
################################################################################

resource "aws_db_event_subscription" "this" {
  count = var.create_db_event_subscription && var.sns_topic_arn != null ? 1 : 0

  name             = var.db_event_subscription_use_name_prefix ? null : coalesce(var.db_event_subscription_name, "${local.identifier}-events")
  name_prefix      = var.db_event_subscription_use_name_prefix ? coalesce(var.db_event_subscription_name, "${local.identifier}-") : null
  sns_topic        = var.sns_topic_arn
  source_type      = "db-instance"
  source_ids       = [aws_db_instance.this.identifier]
  event_categories = var.event_categories
  enabled          = var.event_subscription_enabled

  tags = merge(
    var.tags,
    var.db_event_subscription_tags,
    {
      Name = coalesce(var.db_event_subscription_name, "${local.identifier}-events")
    }
  )
}
