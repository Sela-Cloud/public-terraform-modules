# Azure Key Vault Terraform Child Module

Terraform module to provision an [Azure Key Vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault).

This module manages Azure Key Vault resources, supporting Azure RBAC authorization, inline access policies, network ACL firewall rules, soft-delete retention, purge protection, and resource tagging.

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
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Specifies the name of the Key Vault. Changing this forces a new resource to be created. | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which to create the Key Vault. | `string` | n/a | yes |
| location | Specifies the supported Azure location where the resource exists. | `string` | n/a | yes |
| sku_name | The Name of the SKU used for this Key Vault (`standard` or `premium`). | `string` | n/a | yes |
| tenant_id | The Azure Active Directory tenant ID for authenticating requests. | `string` | n/a | yes |
| rbac_authorization_enabled | Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC). | `bool` | n/a | yes |
| enabled_for_deployment | Boolean flag to specify whether Azure VMs can retrieve certificates as secrets. | `bool` | `false` | no |
| enabled_for_disk_encryption | Boolean flag to specify whether Azure Disk Encryption can retrieve secrets and unwrap keys. | `bool` | `false` | no |
| enabled_for_template_deployment | Boolean flag to specify whether ARM can retrieve secrets during template deployments. | `bool` | `false` | no |
| purge_protection_enabled | Is Purge Protection enabled for this Key Vault? Once enabled, cannot be disabled. | `bool` | `false` | no |
| soft_delete_retention_days | The number of days that items should be retained for once soft-deleted (7-90). | `number` | `90` | no |
| public_network_access_enabled | Whether public network access is allowed for this Key Vault. | `bool` | `true` | no |
| network_acls | Network rules restricting access to the Key Vault. | `object` | `null` | no |
| access_policies | List of access policies for the Key Vault. | `list(object)` | `[]` | no |
| tags | A mapping of tags to assign to the Key Vault. | `map(string)` | `{}` | no |
| timeouts | Custom timeout durations for Key Vault operations. | `object` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Key Vault. |
| name | The Name of the Key Vault. |
| vault_uri | The URI of the Key Vault, used for performing operations on keys and secrets. |
| key_vault | The full Azure Key Vault resource object. |

## Usage Examples

### Key Vault with Azure RBAC Authorization (Recommended)

```hcl
module "key_vault" {
  source = "../../modules/azure/key-vault"

  name                       = "kv-prod-app-01"
  resource_group_name        = "rg-prod-app"
  location                   = "eastus"
  sku_name                   = "standard"
  tenant_id                  = "00000000-0000-0000-0000-000000000000"
  rbac_authorization_enabled = true

  purge_protection_enabled   = true
  soft_delete_retention_days = 90

  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = ["203.0.113.0/24"]
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Key Vault with Access Policies

```hcl
module "key_vault_access_policies" {
  source = "../../modules/azure/key-vault"

  name                       = "kv-dev-app-01"
  resource_group_name        = "rg-dev-app"
  location                   = "eastus"
  sku_name                   = "standard"
  tenant_id                  = "00000000-0000-0000-0000-000000000000"
  rbac_authorization_enabled = false

  access_policies = [
    {
      tenant_id          = "00000000-0000-0000-0000-000000000000"
      object_id          = "11111111-1111-1111-1111-111111111111"
      key_permissions    = ["Get", "List", "Create", "Delete"]
      secret_permissions = ["Get", "List", "Set", "Delete"]
    }
  ]

  tags = {
    Environment = "development"
  }
}
```
