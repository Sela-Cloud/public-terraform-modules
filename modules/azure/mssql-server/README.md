# Azure SQL Database / Microsoft SQL Server Terraform Child Module

Terraform module to provision an [Azure SQL Logical Server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server), [Azure SQL Databases](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database), and [Firewall Rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule).

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
| [azurerm_mssql_server.server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server) | resource |
| [azurerm_mssql_database.database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) | resource |
| [azurerm_mssql_firewall_rule.firewall_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule) | resource |
| [azurerm_mssql_firewall_rule.allow_azure_services](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Microsoft SQL Server (globally unique). | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which to create the SQL Server. | `string` | n/a | yes |
| location | Azure Region for the SQL Server. | `string` | n/a | yes |
| server_version | Version of the server (`12.0`). | `string` | `"12.0"` | no |
| administrator_login | Administrator username for the SQL Server. | `string` | `"sqladmin"` | no |
| administrator_login_password | Password for administrator_login. | `string` | `null` | no |
| minimum_tls_version | Minimum TLS Version (`1.0`, `1.1`, `1.2`). | `string` | `"1.2"` | no |
| public_network_access_enabled | Whether public network access is allowed. | `bool` | `true` | no |
| outbound_network_restriction_enabled | Restrict outbound network traffic. | `bool` | `false` | no |
| connection_policy | Connection policy (`Default`, `Proxy`, `Redirect`). | `string` | `"Default"` | no |
| azuread_administrator | Azure Active Directory administrator block. | `object` | `null` | no |
| identity | Managed identity block. | `object` | `null` | no |
| databases | Map of databases to create on the server. | `map(object)` | `{}` | no |
| firewall_rules | Map of firewall rules to create. | `map(object)` | `{}` | no |
| allow_azure_services_access | Allow Azure services to access server (0.0.0.0 rule). | `bool` | `false` | no |
| tags | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Microsoft SQL Server. |
| name | The Name of the Microsoft SQL Server. |
| fully_qualified_domain_name | The FQDN of the Azure SQL Server. |
| administrator_login | The administrator login name. |
| database_ids | Map of created database names to their resource IDs. |
| firewall_rule_ids | Map of created firewall rule names to their resource IDs. |
| server | The full Microsoft SQL Server resource object. |

## Usage Examples

### Basic Azure SQL Server & Database

```hcl
module "sql_server" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/mssql-server?ref=azure-wip"

  name                         = "sql-prod-eastus"
  resource_group_name          = "rg-prod-databases"
  location                     = "eastus"
  administrator_login          = "sqladmin"
  administrator_login_password = "ComplexPassword123!"

  databases = {
    "app_db" = {
      sku_name    = "S0"
      max_size_gb = 50
    }
  }

  allow_azure_services_access = true

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```
