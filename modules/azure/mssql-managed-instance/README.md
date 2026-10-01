# Azure SQL Managed Instance Terraform Child Module

Terraform module to provision an [Azure SQL Managed Instance](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_managed_instance) and [Managed Databases](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_managed_database).

Azure SQL Managed Instance is an intelligent, scalable cloud database service that combines the broadest SQL Server database engine compatibility with all the benefits of a fully managed and evergreen platform as a service.

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
| [azurerm_mssql_managed_instance.managed_instance](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_managed_instance) | resource |
| [azurerm_mssql_managed_database.managed_database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_managed_database) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the SQL Managed Instance (globally unique). | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which to create the instance. | `string` | n/a | yes |
| location | Azure Region for the SQL Managed Instance. | `string` | n/a | yes |
| sku_name | SKU Name (`GP_Gen5`, `BC_Gen5`, etc.). | `string` | `"GP_Gen5"` | yes |
| vcores | Number of vCores (4, 8, 16, 24, 32, 40, 64, 80). | `number` | `4` | yes |
| storage_size_in_gb | Storage size in GB (32 to 16384 in increments of 32). | `number` | `32` | yes |
| subnet_id | Dedicated subnet ID delegated to Microsoft.Sql/managedInstances. | `string` | n/a | yes |
| license_type | License type (`LicenseIncluded` or `BasePrice`). | `string` | `"LicenseIncluded"` | yes |
| administrator_login | Administrator login name for the SQL Managed Instance. | `string` | `"sqladmin"` | no |
| administrator_login_password | Password for administrator_login. | `string` | `null` | no |
| collation | Collation for the SQL Managed Instance. | `string` | `"SQL_Latin1_General_CP1_CI_AS"` | no |
| timezone_id | Timezone ID. | `string` | `"UTC"` | no |
| minimum_tls_version | Minimum TLS Version (`1.0`, `1.1`, `1.2`). | `string` | `"1.2"` | no |
| proxy_override | Connection routing mode (`Default`, `Proxy`, `Redirect`). | `string` | `"Default"` | no |
| public_data_endpoint_enabled | Enable public data endpoint? | `bool` | `false` | no |
| storage_account_type | Backup storage account type (`GRS`, `LRS`, `ZRS`). | `string` | `"GRS"` | no |
| zone_redundant_enabled | Enable zone redundancy? | `bool` | `false` | no |
| identity | Managed identity block. | `object` | `null` | no |
| azure_active_directory_administrator | Azure Active Directory administrator block. | `object` | `null` | no |
| managed_databases | Map of managed databases to create. | `map(object)` | `{}` | no |
| tags | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the SQL Managed Instance. |
| name | The Name of the SQL Managed Instance. |
| fqdn | The fully qualified domain name of the Managed Instance. |
| administrator_login | The administrator login name. |
| managed_database_ids | Map of created managed database names to their resource IDs. |
| managed_instance | The full SQL Managed Instance resource object. |

## Usage Examples

### Basic SQL Managed Instance

```hcl
module "sql_managed_instance" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/mssql-managed-instance?ref=azure-wip"

  name                = "sqlmi-prod-eastus"
  resource_group_name = "rg-prod-databases"
  location            = "eastus"

  sku_name           = "GP_Gen5"
  vcores             = 4
  storage_size_in_gb = 64
  subnet_id          = "/subscriptions/.../resourceGroups/rg-prod-networking/providers/Microsoft.Network/virtualNetworks/vnet-prod/subnets/snet-sqlmi"
  license_type       = "LicenseIncluded"

  administrator_login          = "sqladmin"
  administrator_login_password = "ComplexPassword123!"

  managed_databases = {
    "app_db" = {
      short_term_retention_days = 14
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```
