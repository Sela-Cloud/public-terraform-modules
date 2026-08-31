locals {
  databases = merge([
    for instance_key, instance in var.cloud_sql : {
      for database in instance.databases : "${instance_key}-${database.name}" => merge(database, {
        instance_key = instance_key
      })
    }
  ]...)

  iam_users = merge([
    for instance_key, instance in var.cloud_sql : {
      for user in instance.iam_users : "${instance_key}-${user.name}" => merge(user, {
        instance_key = instance_key
      })
    }
  ]...)
}

module "cloud_sql_instance" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/cloud-sql-instance?ref=v0.6.6"
  for_each = var.cloud_sql

  project_id                                    = var.project_id
  name                                          = each.value.name
  region                                        = each.value.region
  database_version                              = each.value.database_version
  edition                                       = each.value.edition
  tier                                          = each.value.tier
  availability_type                             = each.value.availability_type
  disk_type                                     = each.value.disk_type
  disk_size                                     = each.value.disk_size
  disk_autoresize                               = each.value.disk_autoresize
  disk_autoresize_limit                         = each.value.disk_autoresize_limit
  ipv4_enabled                                  = each.value.ipv4_enabled
  private_network                               = try(trimspace(each.value.private_network), "") != "" ? each.value.private_network : null
  allocated_ip_range                            = try(trimspace(each.value.allocated_ip_range), "") != "" ? each.value.allocated_ip_range : null
  enable_private_path_for_google_cloud_services = each.value.enable_private_path_for_google_cloud_services
  ssl_mode                                      = each.value.ssl_mode
  authorized_networks                           = each.value.authorized_networks
  deletion_protection                           = each.value.deletion_protection
  deletion_protection_enabled                   = each.value.deletion_protection_enabled
  connector_enforcement                         = try(trimspace(each.value.connector_enforcement), "") != "" ? each.value.connector_enforcement : null
  backup_enabled                                = each.value.backup_enabled
  backup_start_time                             = try(trimspace(each.value.backup_start_time), "") != "" ? each.value.backup_start_time : null
  backup_location                               = try(trimspace(each.value.backup_location), "") != "" ? each.value.backup_location : null
  binary_log_enabled                            = each.value.binary_log_enabled
  point_in_time_recovery_enabled                = each.value.point_in_time_recovery_enabled
  transaction_log_retention_days                = each.value.transaction_log_retention_days
  retained_backups                              = each.value.retained_backups
  maintenance_day                               = try(tonumber(each.value.maintenance_day), null)
  maintenance_hour                              = each.value.maintenance_hour
  maintenance_update_track                      = each.value.maintenance_update_track
  query_insights_enabled                        = each.value.query_insights_enabled
  query_string_length                           = each.value.query_string_length
  query_plans_per_minute                        = each.value.query_plans_per_minute
  record_application_tags                       = each.value.record_application_tags
  record_client_address                         = each.value.record_client_address
  database_flags                                = each.value.database_flags
  password_validation_policy                    = each.value.password_validation_policy
}

module "cloud_sql_database" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/cloud-sql-database?ref=v0.6.6"
  for_each = local.databases

  project_id      = var.project_id
  instance_name   = module.cloud_sql_instance[each.value.instance_key].name
  name            = each.value.name
  charset         = try(trimspace(each.value.charset), "") != "" ? each.value.charset : null
  collation       = try(trimspace(each.value.collation), "") != "" ? each.value.collation : null
  deletion_policy = each.value.deletion_policy
}

module "cloud_sql_user" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/cloud-sql-user?ref=v0.6.6"
  for_each = local.iam_users

  project_id      = var.project_id
  instance_name   = module.cloud_sql_instance[each.value.instance_key].name
  name            = each.value.name
  type            = each.value.type
  iam_member      = each.value.iam_member
  deletion_policy = each.value.deletion_policy
}
