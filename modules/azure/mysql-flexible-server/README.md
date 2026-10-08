# Azure Database for MySQL - Flexible Server Terraform Child Module

Terraform module to provision an [Azure Database for MySQL - Flexible Server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server).

Azure Database for MySQL Flexible Server is a fully managed database service designed to provide more granular control and flexibility over database management functions and configuration settings.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | >= 3.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.0.0, < 5.0.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_mysql_flexible_server.server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server) | resource |
| [azurerm_mysql_flexible_database.database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_database) | resource |
| [azurerm_mysql_flexible_server_firewall_rule.firewall_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server_firewall_rule) | resource |
| [azurerm_mysql_flexible_server_configuration.configuration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mysql_flexible_server_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Specifies the name of the MySQL Flexible Server. | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which the server should exist. | `string` | n/a | yes |
| location | The Azure Region in which the server should exist. | `string` | n/a | yes |
| administrator_login | The Administrator login for the MySQL Flexible Server. | `string` | `"mysqladmin"` | no |
| administrator_password | The Password associated with the administrator_login. | `string` | `null` | no |
| sku_name | The SKU name for the server (e.g. `B_Standard_B1ms`, `GP_Standard_D2ds_v4`). | `string` | `"B_Standard_B1ms"` | no |
| server_version | The version of the server (`5.7` or `8.0.21`). | `string` | `"8.0.21"` | no |
| storage | Storage configuration block (size, IOPS, autogrow). | `object` | `{ size_gb = 20, iops = 360, auto_grow_enabled = true }` | no |
| high_availability | High availability configuration block. | `object` | `null` | no |
| maintenance_window | Maintenance window configuration block. | `object` | `null` | no |
| identity | Managed identity block. | `object` | `null` | no |
| backup_retention_days | Backup retention days (1 to 35). | `number` | `7` | no |
| geo_redundant_backup_enabled | Enable geo-redundant backup? | `bool` | `false` | no |
| delegated_subnet_id | Delegated subnet ID for VNet integration. | `string` | `null` | no |
| private_dns_zone_id | Private DNS zone ID for VNet integration. | `string` | `null` | no |
| public_network_access | Public network access (`Enabled` or `Disabled`). | `string` | `"Enabled"` | no |
| zone | Availability Zone for the server. | `string` | `null` | no |
| create_mode | Creation mode (`Default`, `PointInTimeRestore`, etc.). | `string` | `"Default"` | no |
| databases | Map of databases to create on the server. | `map(object)` | `{}` | no |
| firewall_rules | Map of firewall rules to create. | `map(object)` | `{}` | no |
| server_parameters | Map of server configuration parameters to set. | `map(string)` | `{}` | no |
| tags | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the MySQL Flexible Server. |
| name | The Name of the MySQL Flexible Server. |
| fqdn | The fully qualified domain name of the MySQL Flexible Server. |
| administrator_login | The Administrator login for the MySQL Flexible Server. |
| database_ids | Map of created database names to their resource IDs. |
| firewall_rule_ids | Map of created firewall rule names to their resource IDs. |
| server | The full MySQL Flexible Server resource object. |

## Usage Examples

### Basic MySQL Flexible Server

```hcl
module "mysql_server" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/mysql-flexible-server?ref=azure-wip"

  name                   = "mysql-prod-eastus"
  resource_group_name    = "rg-prod-databases"
  location               = "eastus"
  administrator_login    = "mysqladmin"
  administrator_password = "ComplexPassword123!"

  sku_name       = "GP_Standard_D2ds_v4"
  server_version = "8.0.21"

  storage = {
    size_gb           = 50
    auto_grow_enabled = true
    iops              = 500
  }

  databases = {
    "app_db" = {
      charset   = "utf8mb4"
      collation = "utf8mb4_unicode_ci"
    }
  }

  firewall_rules = {
    "allow_office_ip" = {
      start_ip_address = "203.0.113.1"
      end_ip_address   = "203.0.113.1"
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```
