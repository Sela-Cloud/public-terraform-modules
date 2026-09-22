# Azure Bastion Host Terraform Child Module

Terraform module to provision an [Azure Bastion Host](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host).

Azure Bastion is a fully managed service that provides secure and seamless RDP and SSH access to your virtual machines directly through the Azure portal or native client, without exposing public IP addresses on your VMs.

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
| [azurerm_bastion_host.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Specifies the name of the Bastion Host. Changing this forces a new resource to be created. | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which to create the Bastion Host. | `string` | n/a | yes |
| location | Specifies the supported Azure location where the resource exists. | `string` | n/a | yes |
| ip_configuration | IP configuration block specifying the `subnet_id` (`AzureBastionSubnet` /26 or larger) and optional `public_ip_address_id`. | `object` | n/a | yes |
| sku | The SKU of the Bastion Host (`Developer`, `Basic`, `Standard`, `Premium`). | `string` | `"Standard"` | no |
| scale_units | The number of scale units for the Bastion Host (2-50). Fixed at 2 for `Basic`. | `number` | `2` | no |
| copy_paste_enabled | Is Copy/Paste feature enabled for the Bastion Host. | `bool` | `true` | no |
| file_copy_enabled | Is File Copy feature enabled (Standard/Premium). | `bool` | `false` | no |
| shareable_link_enabled | Is Shareable Link feature enabled (Standard/Premium). | `bool` | `false` | no |
| tunneling_enabled | Is Native Client Tunneling feature enabled (Standard/Premium). | `bool` | `false` | no |
| ip_connect_enabled | Is IP Connect feature enabled (Standard/Premium). | `bool` | `false` | no |
| session_recording_enabled | Is Session Recording feature enabled (Premium only). | `bool` | `false` | no |
| kerberos_enabled | Is Kerberos authentication feature enabled (Standard/Premium). | `bool` | `false` | no |
| zones | List of Availability Zones in which this Bastion Host should be located. | `list(string)` | `null` | no |
| tags | A mapping of tags to assign to the Bastion Host. | `map(string)` | `{}` | no |
| timeouts | Custom timeout durations for resource operations. | `object` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Bastion Host. |
| name | The Name of the Bastion Host. |
| dns_name | The fully qualified domain name (FQDN) for the Bastion Host. |
| bastion_host | The full Azure Bastion Host resource object. |

## Usage Examples

### Standard SKU with Native Client Tunneling

```hcl
module "bastion" {
  source = "../../modules/azure/bastion-host"

  name                = "bastion-prod"
  resource_group_name = "rg-prod-networking"
  location            = "eastus"
  sku                 = "Standard"
  scale_units         = 2

  copy_paste_enabled     = true
  file_copy_enabled      = true
  shareable_link_enabled = true
  tunneling_enabled      = true
  ip_connect_enabled     = true

  ip_configuration = {
    name                 = "bastion-ip-config"
    subnet_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-prod-networking/providers/Microsoft.Network/virtualNetworks/vnet-prod/subnets/AzureBastionSubnet"
    public_ip_address_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-prod-networking/providers/Microsoft.Network/publicIPAddresses/pip-bastion"
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### Basic SKU

```hcl
module "bastion_basic" {
  source = "../../modules/azure/bastion-host"

  name                = "bastion-dev"
  resource_group_name = "rg-dev-networking"
  location            = "eastus"
  sku                 = "Basic"

  ip_configuration = {
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }

  tags = {
    Environment = "development"
  }
}
```
