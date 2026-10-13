# AWS RDS Terraform Module

A production-ready Terraform module to deploy and manage Amazon Relational Database Service (RDS) instances supporting **MySQL** and **PostgreSQL** engines with comprehensive security, high availability, backup, and monitoring options.

All resources are consolidated into a unified `main.tf` for seamless maintenance and clean dependency orchestration.

---

## Features

- **Multi-Engine Support**: Pre-configured defaults and automated parameter/port selection for **MySQL** (default port `3306`, family `mysql8.0`) and **PostgreSQL** (default port `5432`, family `postgres16`).
- **AWS Secrets Manager Integration**: Native support for `manage_master_user_password = true` to automatically generate and rotate credentials via AWS Secrets Manager.
- **DB Subnet Group**: Automatic creation of DB subnet group across multiple Availability Zones or association with existing subnet groups.
- **Custom Parameter Groups**: Configurable parameter groups with custom engine family parameters.
- **Option Groups**: Support for optional DB option groups (e.g., MariaDB audit plugin, native extensions).
- **Dedicated Security Group**: Optional automated creation of security groups with fine-grained inbound rules for CIDRs and referenced security groups.
- **Enhanced Monitoring**: Automatic creation of IAM role and policy attachment for CloudWatch Enhanced Monitoring.
- **Storage Autoscaling**: Provisioned `gp3` storage with optional autoscaling up to `max_allocated_storage`.
- **High Availability & Backups**: Automated backups, retention period controls, maintenance windows, Multi-AZ, and final snapshot protections.

---

## Architecture Diagram

```mermaid
graph TD
    Client[Application / VPC Traffic] -->|Inbound Port 3306 or 5432| SG[RDS Security Group]
    SG --> RDS[Amazon RDS DB Instance]
    RDS --> SubnetGroup[DB Subnet Group - Multi AZ]
    RDS --> ParamGroup[DB Parameter Group]
    RDS --> SecretsMgr[AWS Secrets Manager - Master Password]
    RDS --> EnhancedMon[Enhanced Monitoring IAM Role / CloudWatch]
```

---

## Usage Examples

### 1. MySQL Instance

```hcl
module "rds_mysql" {
  source = "../../modules/aws/rds"

  identifier     = "my-mysql-db"
  engine         = "mysql"
  engine_version = "8.0.35"
  instance_class = "db.t4g.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"

  db_name                     = "ecommerce"
  username                    = "dbadmin"
  manage_master_user_password = true

  vpc_id                = "vpc-0123456789abcdef0"
  subnet_ids            = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]
  allowed_cidr_blocks   = ["10.0.0.0/16"]

  multi_az            = false
  skip_final_snapshot = true

  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  tags = {
    Environment = "production"
    Terraform   = "true"
  }
}
```

### 2. PostgreSQL Instance with Multi-AZ

```hcl
module "rds_postgres" {
  source = "../../modules/aws/rds"

  identifier     = "my-postgres-db"
  engine         = "postgres"
  engine_version = "16.1"
  instance_class = "db.t4g.small"

  allocated_storage     = 50
  max_allocated_storage = 200
  storage_type          = "gp3"

  db_name                     = "analytics"
  username                    = "postgres"
  manage_master_user_password = true

  vpc_id              = "vpc-0123456789abcdef0"
  subnet_ids          = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]
  allowed_cidr_blocks = ["10.0.0.0/16"]

  multi_az                = true
  deletion_protection     = true
  backup_retention_period = 14
  skip_final_snapshot     = false

  monitoring_interval    = 60
  create_monitoring_role = true

  create_db_parameter_group = true
  family                    = "postgres16"
  parameters = [
    {
      name  = "log_min_duration_statement"
      value = "1000"
    }
  ]

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = {
    Environment = "production"
    Terraform   = "true"
  }
}
```

---

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0 |

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| identifier | The name of the RDS instance. Set at most one of identifier/identifier_prefix | `string` | n/a | yes |
| identifier_prefix | Creates a unique identifier beginning with this prefix. Takes precedence over identifier | `string` | `null` | no |
| engine | The database engine (`mysql`, `postgres`, `mariadb`) | `string` | `"mysql"` | no |
| engine_version | Database engine version | `string` | `null` | no |
| instance_class | RDS instance type | `string` | `"db.t4g.micro"` | no |
| license_model | License model. Defaults to the engine's own default | `string` | `null` | no |
| character_set_name | Character set to use on creation, for engines that support it | `string` | `null` | no |
| allocated_storage | Allocated storage in GB | `number` | `20` | no |
| max_allocated_storage | Upper limit for storage autoscaling in GB | `number` | `100` | no |
| storage_type | Storage type (`gp3`, `gp2`, `io1`, `io2`, `standard`) | `string` | `"gp3"` | no |
| iops | Provisioned IOPS. Only applies to gp3/io1/io2 | `number` | `null` | no |
| storage_throughput | Storage throughput in MB/s. Only applies to gp3 | `number` | `null` | no |
| dedicated_log_volume | Use a dedicated log volume (DLV) | `bool` | `false` | no |
| storage_encrypted | Whether storage encryption is enabled | `bool` | `true` | no |
| kms_key_id | KMS Key ARN for storage encryption | `string` | `null` | no |
| db_name | Name of the database to create | `string` | `null` | no |
| username | Master username | `string` | `null` | no |
| password | Master password (when manage_master_user_password is false) | `string` | `null` | no |
| manage_master_user_password | Manage password with AWS Secrets Manager | `bool` | `true` | no |
| master_user_secret_kms_key_id | KMS Key for Secrets Manager master user secret | `string` | `null` | no |
| port | Port for DB connections (3306 for MySQL, 5432 for Postgres) | `number` | `null` | no |
| multi_az | Whether instance is Multi-AZ | `bool` | `false` | no |
| availability_zone | AZ to place a single-AZ instance in. Ignored when multi_az is true | `string` | `null` | no |
| publicly_accessible | Whether instance is publicly accessible | `bool` | `false` | no |
| network_type | `IPV4` or `DUAL` (dual-stack) | `string` | `"IPV4"` | no |
| ca_cert_identifier | CA certificate identifier, e.g. `rds-ca-rsa2048-g1` | `string` | `null` | no |
| vpc_id | VPC ID for dedicated security group | `string` | `null` | no |
| vpc_security_group_ids | Existing security group IDs to attach | `list(string)` | `[]` | no |
| create_db_subnet_group | Whether to create a dedicated DB subnet group | `bool` | `true` | no |
| db_subnet_group_name / db_subnet_group_use_name_prefix / db_subnet_group_description / db_subnet_group_tags | DB subnet group naming and tags | various | `null`/`false`/`null`/`{}` | no |
| subnet_ids | VPC Subnet IDs for DB subnet group (at least 2, in different AZs) | `list(string)` | `[]` | no |
| create_security_group | Whether to create a dedicated security group | `bool` | `true` | no |
| security_group_name / security_group_use_name_prefix / security_group_description / security_group_tags | Dedicated security group naming and tags | various | `null`/`false`/`null`/`{}` | no |
| allowed_cidr_blocks | Ingress IPv4 CIDR blocks for DB port | `list(string)` | `[]` | no |
| allowed_ipv6_cidr_blocks | Ingress IPv6 CIDR blocks for DB port | `list(string)` | `[]` | no |
| allowed_security_group_ids | Ingress Security Group IDs for DB port | `list(string)` | `[]` | no |
| backup_retention_period | Retention period in days (0-35) | `number` | `7` | no |
| backup_window / maintenance_window | Daily backup / weekly maintenance windows (UTC) | `string` | see variables.tf | no |
| copy_tags_to_snapshot | Copy instance tags to snapshots | `bool` | `true` | no |
| skip_final_snapshot | Skip snapshot before deletion | `bool` | `true` | no |
| final_snapshot_identifier | Final snapshot name. Defaults to `<identifier>-final-snapshot` | `string` | `null` | no |
| delete_automated_backups | Remove automated backups when the instance is deleted | `bool` | `true` | no |
| deletion_protection | Protect from accidental deletion | `bool` | `false` | no |
| auto_minor_version_upgrade | Apply minor engine updates automatically | `bool` | `true` | no |
| allow_major_version_upgrade | Allow major engine version upgrades | `bool` | `false` | no |
| apply_immediately | Apply modifications immediately instead of at the next maintenance window | `bool` | `false` | no |
| snapshot_identifier | Restore from this DB snapshot identifier/ARN | `string` | `null` | no |
| replicate_source_db | Source DB identifier/ARN to create a read replica of | `string` | `null` | no |
| monitoring_interval | Enhanced monitoring interval in seconds | `number` | `0` | no |
| create_monitoring_role | Automatically create IAM role for monitoring | `bool` | `false` | no |
| monitoring_role_arn | Existing IAM role ARN for monitoring (when not auto-creating) | `string` | `null` | no |
| monitoring_role_name / monitoring_role_tags | Created monitoring role naming and tags | various | `null`/`{}` | no |
| performance_insights_enabled | Enable Performance Insights | `bool` | `false` | no |
| performance_insights_kms_key_id | KMS key for Performance Insights data | `string` | `null` | no |
| performance_insights_retention_period | 7 or 731 days | `number` | `7` | no |
| iam_database_authentication_enabled | Allow IAM-credential database authentication | `bool` | `false` | no |
| enabled_cloudwatch_logs_exports | Log types to export to CloudWatch | `list(string)` | `[]` | no |
| create_db_parameter_group / parameter_group_name / parameter_group_use_name_prefix / family / parameter_group_description / parameters / parameter_group_tags | DB parameter group creation and custom parameters | various | see variables.tf | no |
| create_db_option_group / option_group_name / option_group_use_name_prefix / major_engine_version / option_group_description / options / option_group_tags | DB option group creation (engine-specific options, e.g. Oracle TDE) | various | see variables.tf | no |
| domain / domain_iam_role_name / domain_auth_secret_arn / domain_dns_ips | Join a Directory Service Active Directory domain | various | `null` | no |
| custom_iam_instance_profile | Instance profile for an RDS Custom DB instance | `string` | `null` | no |
| blue_green_update | `{enabled}` to use Blue/Green deployments for updates | `object` | `null` | no |
| restore_to_point_in_time | Point-in-time restore source and target time | `object` | `null` | no |
| s3_import | Restore a per-engine backup stored in S3 | `object` | `null` | no |
| role_associations | IAM roles for engine features (e.g. S3 import/export). Each needs a unique `key` (Terraform-only) | `list(object)` | `[]` | no |
| create_db_event_subscription / db_event_subscription_name / db_event_subscription_use_name_prefix / sns_topic_arn / event_categories / event_subscription_enabled / db_event_subscription_tags | RDS event notifications to an SNS topic | various | see variables.tf | no |
| timeouts | `{create, update, delete}` operation timeouts | `object` | `{60m, 60m, 60m}` | no |
| tags | Resource tags | `map(string)` | `{}` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the RDS instance |
| arn | The ARN of the RDS instance |
| endpoint | Connection endpoint (`address:port`) |
| db_instance_address | Hostname of the RDS instance |
| db_instance_port | Port of the RDS instance |
| db_instance_name | The database name |
| db_master_user_secret | Secrets Manager metadata for master user password |
| db_subnet_group_id | ID/Name of the DB subnet group |
| db_parameter_group_id | ID/Name of the DB parameter group |
| security_group_id | ID of the created dedicated security group |
| monitoring_role_arn | ARN of the Enhanced Monitoring IAM role |
