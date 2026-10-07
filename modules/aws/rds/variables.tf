################################################################################
# General / Core Database Configuration
################################################################################

variable "identifier" {
  description = "The name of the RDS instance. Must be unique within the AWS Region. If omitted and identifier_prefix is specified, Terraform assigns a unique identifier."
  type        = string
  default     = null
}

variable "identifier_prefix" {
  description = "Creates a unique identifier beginning with the specified prefix."
  type        = string
  default     = null
}

variable "engine" {
  description = "The database engine to use (e.g. 'mysql', 'postgres', 'mariadb')."
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "The engine version to use. If not specified, the latest default version for the engine will be used."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "The instance type of the RDS instance (e.g. 'db.t4g.micro', 'db.t3.micro', 'db.r6g.large')."
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance (in GB). Set to null or 0 to disable autoscaling."
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), 'gp3' (general purpose SSD), 'io1' (provisioned IOPS SSD), or 'io2'."
  type        = string
  default     = "gp3"
}

variable "iops" {
  description = "The amount of provisioned IOPS. Setting this requires storage_type to be gp3, io1, or io2."
  type        = number
  default     = null
}

variable "storage_throughput" {
  description = "The storage throughput in MB/s for gp3 storage (between 125 and 1000 MB/s)."
  type        = number
  default     = null
}

variable "dedicated_log_volume" {
  description = "Use a dedicated log volume (DLV) for the DB instance."
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. If not specified, the default AWS KMS key for RDS will be used when storage_encrypted is true."
  type        = string
  default     = null
}

variable "license_model" {
  description = "License model information for this DB instance. Defaults to engine default ('general-public-license' for MySQL, 'postgresql-license' for PostgreSQL)."
  type        = string
  default     = null
}

variable "character_set_name" {
  description = "The character set name to use on DB creation in supported engines."
  type        = string
  default     = null
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created."
  type        = string
  default     = null
}

variable "username" {
  description = "Username for the master DB user. If null, defaults to 'admin' for MySQL or 'postgres' for PostgreSQL."
  type        = string
  default     = null
}

variable "password" {
  description = "Password for the master DB user. Required if manage_master_user_password is false and not restoring from snapshot."
  type        = string
  default     = null
  sensitive   = true
}

variable "manage_master_user_password" {
  description = "Set to true to allow RDS to manage the master user password in AWS Secrets Manager (recommended best practice)."
  type        = bool
  default     = true
}

variable "master_user_secret_kms_key_id" {
  description = "The KMS key ARN to use for the Secrets Manager secret when manage_master_user_password is true."
  type        = string
  default     = null
}

variable "port" {
  description = "The port on which the DB accepts connections. If null, defaults to 3306 for MySQL or 5432 for PostgreSQL."
  type        = number
  default     = null
}

################################################################################
# High Availability and Networking
################################################################################

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ."
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "The Availability Zone of the RDS instance. Ignored if multi_az is true."
  type        = string
  default     = null
}

variable "publicly_accessible" {
  description = "Control if instance is publicly accessible."
  type        = bool
  default     = false
}

variable "network_type" {
  description = "The network type of the DB instance ('IPV4' or 'DUAL')."
  type        = string
  default     = "IPV4"
}

variable "ca_cert_identifier" {
  description = "The identifier of the CA certificate for the DB instance (e.g. 'rds-ca-rsa2048-g1')."
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of existing VPC security groups to associate with the DB."
  type        = list(string)
  default     = []
}

################################################################################
# DB Subnet Group
################################################################################

variable "create_db_subnet_group" {
  description = "Whether to create a new DB subnet group."
  type        = bool
  default     = true
}

variable "db_subnet_group_name" {
  description = "Name of DB subnet group. Required if create_db_subnet_group is false and not using the default subnet group."
  type        = string
  default     = null
}

variable "db_subnet_group_use_name_prefix" {
  description = "Determines whether to use db_subnet_group_name as is or create a unique name beginning with db_subnet_group_name as prefix."
  type        = bool
  default     = false
}

variable "db_subnet_group_description" {
  description = "Description of the DB subnet group."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "A list of VPC subnet IDs for the DB subnet group. Required if create_db_subnet_group is true."
  type        = list(string)
  default     = []
}

variable "db_subnet_group_tags" {
  description = "Additional tags for the DB subnet group."
  type        = map(string)
  default     = {}
}

################################################################################
# DB Parameter Group
################################################################################

variable "create_db_parameter_group" {
  description = "Whether to create a new DB parameter group."
  type        = bool
  default     = true
}

variable "parameter_group_name" {
  description = "Name of the DB parameter group to associate or create."
  type        = string
  default     = null
}

variable "parameter_group_use_name_prefix" {
  description = "Determines whether to use parameter_group_name as is or create a unique name beginning with parameter_group_name as prefix."
  type        = bool
  default     = false
}

variable "family" {
  description = "The family of the DB parameter group (e.g. 'mysql8.0', 'postgres16'). If null, defaults based on engine."
  type        = string
  default     = null
}

variable "parameter_group_description" {
  description = "Description of the DB parameter group."
  type        = string
  default     = null
}

variable "parameters" {
  description = "A list of DB parameter maps to apply."
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string)
  }))
  default = []
}

variable "parameter_group_tags" {
  description = "Additional tags for the DB parameter group."
  type        = map(string)
  default     = {}
}

################################################################################
# DB Option Group
################################################################################

variable "create_db_option_group" {
  description = "Whether to create a new DB option group."
  type        = bool
  default     = false
}

variable "option_group_name" {
  description = "Name of the DB option group to associate or create."
  type        = string
  default     = null
}

variable "option_group_use_name_prefix" {
  description = "Determines whether to use option_group_name as is or create a unique name beginning with option_group_name as prefix."
  type        = bool
  default     = false
}

variable "major_engine_version" {
  description = "Specifies the major version of the engine that this option group should be associated with (e.g. '8.0' or '16')."
  type        = string
  default     = null
}

variable "option_group_description" {
  description = "Description of the DB option group."
  type        = string
  default     = null
}

variable "options" {
  description = "A list of Options to apply."
  type        = any
  default     = []
}

variable "option_group_tags" {
  description = "Additional tags for the DB option group."
  type        = map(string)
  default     = {}
}

################################################################################
# Security Group
################################################################################

variable "create_security_group" {
  description = "Whether to create a dedicated security group for the RDS instance."
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "The VPC ID where the security group will be created. Required if create_security_group is true."
  type        = string
  default     = null
}

variable "security_group_name" {
  description = "Name of the security group to create. If null, defaults to '<identifier>-sg'."
  type        = string
  default     = null
}

variable "security_group_use_name_prefix" {
  description = "Determines whether to use security_group_name as is or create a unique name beginning with security_group_name as prefix."
  type        = bool
  default     = false
}

variable "security_group_description" {
  description = "Description of the security group."
  type        = string
  default     = null
}

variable "allowed_cidr_blocks" {
  description = "List of IPv4 CIDR blocks to allow ingress traffic on the DB port."
  type        = list(string)
  default     = []
}

variable "allowed_ipv6_cidr_blocks" {
  description = "List of IPv6 CIDR blocks to allow ingress traffic on the DB port."
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "List of Security Group IDs to allow ingress traffic on the DB port."
  type        = list(string)
  default     = []
}

variable "security_group_tags" {
  description = "Additional tags for the security group."
  type        = map(string)
  default     = {}
}

################################################################################
# Backups and Maintenance
################################################################################

variable "backup_retention_period" {
  description = "The days to retain backups for. Must be between 0 and 35."
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if automated backups are enabled."
  type        = string
  default     = "03:00-04:00"
}

variable "copy_tags_to_snapshot" {
  description = "Copy all Instance tags to snapshots."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted."
  type        = bool
  default     = true
}

variable "final_snapshot_identifier" {
  description = "The name of your final DB snapshot when this DB instance is deleted. If null and skip_final_snapshot is false, defaults to '<identifier>-final-snapshot'."
  type        = string
  default     = null
}

variable "maintenance_window" {
  description = "The window to perform maintenance in (UTC format, e.g. 'Mon:04:00-Mon:05:00')."
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window."
  type        = bool
  default     = true
}

variable "allow_major_version_upgrade" {
  description = "Indicates that major version upgrades are allowed."
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "The database can't be deleted when this value is set to true."
  type        = bool
  default     = false
}

variable "delete_automated_backups" {
  description = "Specifies whether to remove automated backups immediately after the DB instance is deleted."
  type        = bool
  default     = true
}

################################################################################
# Monitoring and Logging
################################################################################

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to enable for exporting to CloudWatch logs. MySQL: ['error', 'general', 'slowquery']; PostgreSQL: ['postgresql', 'upgrade']."
  type        = list(string)
  default     = []
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected. Valid Values: 0, 1, 5, 10, 15, 30, 60."
  type        = number
  default     = 0
}

variable "monitoring_role_arn" {
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs."
  type        = string
  default     = null
}

variable "create_monitoring_role" {
  description = "Whether to create the IAM role for RDS Enhanced Monitoring when monitoring_interval > 0."
  type        = bool
  default     = false
}

variable "monitoring_role_name" {
  description = "Name of the IAM role to create for Enhanced Monitoring."
  type        = string
  default     = null
}

variable "monitoring_role_tags" {
  description = "Additional tags for the monitoring IAM role."
  type        = map(string)
  default     = {}
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights are enabled."
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data."
  type        = string
  default     = null
}

variable "performance_insights_retention_period" {
  description = "Amount of time in days to retain Performance Insights data. Valid values are 7 or 731 (2 years)."
  type        = number
  default     = 7
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether IAM Database Authentication is enabled."
  type        = bool
  default     = false
}

################################################################################
# Advanced / Optional Settings
################################################################################

variable "snapshot_identifier" {
  description = "Specifies whether or not to create this database from a snapshot."
  type        = string
  default     = null
}

variable "replicate_source_db" {
  description = "Specifies that this resource is a Replicate database, and gives the source database identifier or ARN."
  type        = string
  default     = null
}

variable "domain" {
  description = "The ID of the Directory Service Active Directory domain to create the instance in."
  type        = string
  default     = null
}

variable "domain_iam_role_name" {
  description = "The name of the IAM role to be used when making API calls to the Directory Service."
  type        = string
  default     = null
}

variable "domain_auth_secret_arn" {
  description = "The ARN for the Secrets Manager secret with the credentials for the user joining the domain."
  type        = string
  default     = null
}

variable "domain_dns_ips" {
  description = "The list of IP addresses of primary and secondary Active Directory domain controllers."
  type        = list(string)
  default     = null
}

variable "custom_iam_instance_profile" {
  description = "The instance profile associated with the underlying Amazon EC2 instance of an RDS Custom DB instance."
  type        = string
  default     = null
}

variable "blue_green_update" {
  description = "Enables low-downtime updates using RDS Blue/Green deployments."
  type = object({
    enabled = optional(bool)
  })
  default = null
}

variable "restore_to_point_in_time" {
  description = "Restore to a point in time configuration."
  type = object({
    restore_time                             = optional(string)
    source_db_instance_automated_backups_arn = optional(string)
    source_db_instance_identifier            = optional(string)
    source_dbi_resource_id                   = optional(string)
    use_latest_restorable_time               = optional(bool)
  })
  default = null
}

variable "s3_import" {
  description = "Restore from a per-engine backup stored in S3."
  type = object({
    bucket_name           = string
    bucket_prefix         = optional(string)
    ingestion_role        = string
    source_engine         = string
    source_engine_version = string
  })
  default = null
}

################################################################################
# IAM Role Associations & Event Subscription
################################################################################

variable "role_associations" {
  description = "Map of IAM roles to associate with the DB instance (e.g. S3 import/export)."
  type = map(object({
    feature_name = string
    role_arn     = string
  }))
  default = {}
}

variable "create_db_event_subscription" {
  description = "Whether to create an RDS DB event subscription."
  type        = bool
  default     = false
}

variable "db_event_subscription_name" {
  description = "The name of the DB event subscription."
  type        = string
  default     = null
}

variable "db_event_subscription_use_name_prefix" {
  description = "Determines whether to use db_event_subscription_name as prefix."
  type        = bool
  default     = false
}

variable "sns_topic_arn" {
  description = "The SNS topic to send events to."
  type        = string
  default     = null
}

variable "event_categories" {
  description = "A list of event categories for a SourceType that you want to subscribe to."
  type        = list(string)
  default     = null
}

variable "event_subscription_enabled" {
  description = "A boolean flag to enable/disable the DB event subscription."
  type        = bool
  default     = true
}

variable "db_event_subscription_tags" {
  description = "Additional tags for the DB event subscription."
  type        = map(string)
  default     = {}
}

variable "timeouts" {
  description = "Updated Terraform resource management runtimes."
  type = object({
    create = optional(string, "60m")
    update = optional(string, "60m")
    delete = optional(string, "60m")
  })
  default = {}
}

variable "tags" {
  description = "A mapping of tags to assign to all resources."
  type        = map(string)
  default     = {}
}
