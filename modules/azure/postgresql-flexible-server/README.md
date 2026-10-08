# Azure Database for PostgreSQL - Flexible Server Terraform Child Module

Terraform module to provision an [Azure Database for PostgreSQL - Flexible Server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server).

Azure Database for PostgreSQL Flexible Server is a fully managed PostgreSQL database service with zone redundancy, automatic backups, customizable server parameters, and built-in connection pooling.

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
| [azurerm_postgresql_flexible_server.server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server) | resource |
| [azurerm_postgresql_flexible_server_database.database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_database) | resource |
| [azurerm_postgresql_flexible_server_firewall_rule.firewall_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_firewall_rule) | resource |
| [azurerm_postgresql_flexible_server_configuration.configuration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the PostgreSQL Flexible Server. | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which the server should exist. | `string` | n/a | yes |
| location | The Azure Region where the server should exist. | `string` | n/a | yes |
| administrator_login | The Administrator login for the server. | `string` | `"pgadmin"` | no |
| administrator_password | The Password associated with administrator_login. | `string` | `null` | no |
| sku_name | The SKU Name for the server (e.g. `B_Standard_B1ms`, `GP_Standard_D2s_v3`). | `string` | `"B_Standard_B1ms"` | no |
| server_version | The version of PostgreSQL to use (`11`, `12`, `13`, `14`, `15`, `16`). | `string` | `"16"` | no |
| storage_mb | Max storage allowed for the server in megabytes. | `number` | `32768` | no |
| storage_tier | Storage tier for the server (e.g. `P4`, `P6`, `P10`, `P15`, `P20`, `P30`). | `string` | `null` | no |
| auto_grow_enabled | Should storage auto-grow be enabled? | `bool` | `true` | no |
| backup_retention_days | Backup retention days (7 to 35). | `number` | `7` | no |
| geo_redundant_backup_enabled | Enable geo-redundant backup? | `bool` | `false` | no |
| delegated_subnet_id | Delegated subnet ID for VNet integration. | `string` | `null` | no |
| private_dns_zone_id | Private DNS zone ID for VNet integration. | `string` | `null` | no |
| public_network_access_enabled | Public network access allowed? | `bool` | `true` | no |
| zone | Availability Zone for the server. | `string` | `null` | no |
| high_availability | High availability configuration block. | `object` | `null` | no |
| maintenance_window | Maintenance window configuration block. | `object` | `null` | no |
| authentication | Azure AD / Entra authentication block. | `object` | `null` | no |
| identity | Managed identity configuration block. | `object` | `null` | no |
| databases | Map of databases to create on the server. | `map(object)` | `{}` | no |
| firewall_rules | Map of firewall rules to create. | `map(object)` | `{}` | no |
| server_parameters | Map of server parameters / configurations to set. | `map(string)` | `{}` | no |
| tags | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the PostgreSQL Flexible Server. |
| name | The Name of the PostgreSQL Flexible Server. |
| fqdn | The FQDN of the PostgreSQL Flexible Server. |
| administrator_login | The Administrator login for the server. |
| database_ids | Map of created database names to their resource IDs. |
| firewall_rule_ids | Map of created firewall rule names to their resource IDs. |
| server | The full PostgreSQL Flexible Server resource object. |

## Usage Examples

### Basic PostgreSQL Flexible Server

```hcl
module "postgresql_server" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/postgresql-flexible-server?ref=azure-wip"

  name                   = "psql-prod-eastus"
  resource_group_name    = "rg-prod-databases"
  location               = "eastus"
  administrator_login    = "pgadmin"
  administrator_password = "ComplexPassword123!"

  sku_name       = "GP_Standard_D2s_v3"
  server_version = "16"
  storage_mb     = 65536

  databases = {
    "app_db" = {
      charset   = "UTF8"
      collation = "en_US.utf8"
    }
  }

  firewall_rules = {
    "allow_office" = {
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
