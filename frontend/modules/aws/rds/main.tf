/******************************************
  AWS RDS Root Module
 *****************************************/

module "rds" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/rds?ref=v0.9.5"
  for_each = var.rds

  identifier        = coalesce(each.value.identifier, each.key)
  identifier_prefix = each.value.identifier_prefix
  engine            = each.value.engine
  engine_version    = each.value.engine_version
  instance_class    = each.value.instance_class

  allocated_storage     = each.value.allocated_storage
  max_allocated_storage = each.value.max_allocated_storage
  storage_type          = each.value.storage_type
  iops                  = each.value.iops
  storage_throughput    = each.value.storage_throughput
  dedicated_log_volume  = each.value.dedicated_log_volume
  storage_encrypted     = each.value.storage_encrypted
  kms_key_id            = each.value.kms_key_id
  license_model         = each.value.license_model
  character_set_name    = each.value.character_set_name

  db_name                       = each.value.db_name
  username                      = each.value.username
  password                      = each.value.password
  manage_master_user_password   = each.value.manage_master_user_password
  master_user_secret_kms_key_id = each.value.master_user_secret_kms_key_id
  port                          = each.value.port

  multi_az               = each.value.multi_az
  availability_zone      = each.value.availability_zone
  publicly_accessible    = each.value.publicly_accessible
  network_type           = each.value.network_type
  ca_cert_identifier     = each.value.ca_cert_identifier
  vpc_security_group_ids = each.value.vpc_security_group_ids

  create_db_subnet_group          = each.value.create_db_subnet_group
  db_subnet_group_name            = each.value.db_subnet_group_name
  db_subnet_group_use_name_prefix = each.value.db_subnet_group_use_name_prefix
  db_subnet_group_description     = each.value.db_subnet_group_description
  subnet_ids                      = each.value.subnet_ids
  db_subnet_group_tags            = each.value.db_subnet_group_tags

  create_db_parameter_group       = each.value.create_db_parameter_group
  parameter_group_name            = each.value.parameter_group_name
  parameter_group_use_name_prefix = each.value.parameter_group_use_name_prefix
  family                          = each.value.family
  parameter_group_description     = each.value.parameter_group_description
  parameters                      = each.value.parameters
  parameter_group_tags            = each.value.parameter_group_tags

  create_db_option_group       = each.value.create_db_option_group
  option_group_name            = each.value.option_group_name
  option_group_use_name_prefix = each.value.option_group_use_name_prefix
  major_engine_version         = each.value.major_engine_version
  option_group_description     = each.value.option_group_description
  options                      = each.value.options
  option_group_tags            = each.value.option_group_tags

  create_security_group          = each.value.create_security_group
  vpc_id                         = each.value.vpc_id
  security_group_name            = each.value.security_group_name
  security_group_use_name_prefix = each.value.security_group_use_name_prefix
  security_group_description     = each.value.security_group_description
  allowed_cidr_blocks            = each.value.allowed_cidr_blocks
  allowed_ipv6_cidr_blocks       = each.value.allowed_ipv6_cidr_blocks
  allowed_security_group_ids     = each.value.allowed_security_group_ids
  security_group_tags            = each.value.security_group_tags

  backup_retention_period   = each.value.backup_retention_period
  backup_window             = each.value.backup_window
  copy_tags_to_snapshot     = each.value.copy_tags_to_snapshot
  skip_final_snapshot       = each.value.skip_final_snapshot
  final_snapshot_identifier = each.value.final_snapshot_identifier
  maintenance_window        = each.value.maintenance_window

  auto_minor_version_upgrade  = each.value.auto_minor_version_upgrade
  allow_major_version_upgrade = each.value.allow_major_version_upgrade
  apply_immediately           = each.value.apply_immediately
  deletion_protection         = each.value.deletion_protection
  delete_automated_backups    = each.value.delete_automated_backups

  enabled_cloudwatch_logs_exports = each.value.enabled_cloudwatch_logs_exports

  monitoring_interval    = each.value.monitoring_interval
  monitoring_role_arn    = each.value.monitoring_role_arn
  create_monitoring_role = each.value.create_monitoring_role
  monitoring_role_name   = each.value.monitoring_role_name
  monitoring_role_tags   = each.value.monitoring_role_tags

  performance_insights_enabled          = each.value.performance_insights_enabled
  performance_insights_kms_key_id       = each.value.performance_insights_kms_key_id
  performance_insights_retention_period = each.value.performance_insights_retention_period

  iam_database_authentication_enabled = each.value.iam_database_authentication_enabled

  snapshot_identifier         = each.value.snapshot_identifier
  replicate_source_db         = each.value.replicate_source_db
  domain                      = each.value.domain
  domain_iam_role_name        = each.value.domain_iam_role_name
  domain_auth_secret_arn      = each.value.domain_auth_secret_arn
  domain_dns_ips              = each.value.domain_dns_ips
  custom_iam_instance_profile = each.value.custom_iam_instance_profile

  blue_green_update        = each.value.blue_green_update
  restore_to_point_in_time = each.value.restore_to_point_in_time
  s3_import                = each.value.s3_import
  timeouts                 = each.value.timeouts

  role_associations                     = each.value.role_associations
  create_db_event_subscription          = each.value.create_db_event_subscription
  db_event_subscription_name            = each.value.db_event_subscription_name
  db_event_subscription_use_name_prefix = each.value.db_event_subscription_use_name_prefix
  sns_topic_arn                         = each.value.sns_topic_arn
  event_categories                      = each.value.event_categories
  event_subscription_enabled            = each.value.event_subscription_enabled
  db_event_subscription_tags            = each.value.db_event_subscription_tags

  tags = each.value.tags
}
