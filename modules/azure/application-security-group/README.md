# Azure Application Security Group Terraform Child Module

Terraform module to provision an [Azure Application Security Group (ASG)](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_security_group).

Application Security Groups enable you to configure network security as a natural extension of an application's structure, allowing you to group virtual machines or network interfaces and define network security policies based on those groups.

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
| [azurerm_application_security_group.asg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_security_group) | resource |
| [azurerm_network_interface_application_security_group_association.nic_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_application_security_group_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Application Security Group. Changing this forces a new resource to be created. | `string` | `"asg-default"` | no |
| resource_group_name | The name of the resource group in which to create the Application Security Group. Changing this forces a new resource to be created. | `string` | `"rg-default"` | no |
| location | The Azure Region where the Application Security Group should exist. Changing this forces a new resource to be created. | `string` | `"eastus"` | no |
| tags | A mapping of tags which should be assigned to the Application Security Group. | `map(string)` | `{}` | no |
| network_interface_ids | Optional list of Network Interface IDs to associate with this Application Security Group. | `list(string)` | `[]` | no |
| timeouts | Custom timeout durations for resource operations (create, read, update, delete). | `object` | `{}` | no |

### Timeouts Object Definition

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| create | Timeout for creating the resource (e.g. `"30m"`). | `string` | `null` | no |
| read | Timeout for reading the resource (e.g. `"5m"`). | `string` | `null` | no |
| update | Timeout for updating the resource (e.g. `"30m"`). | `string` | `null` | no |
| delete | Timeout for deleting the resource (e.g. `"30m"`). | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Application Security Group. |
| name | The Name of the Application Security Group. |
| resource_group_name | The name of the Resource Group in which the Application Security Group was created. |
| location | The Azure Region of the Application Security Group. |
| tags | The tags assigned to the Application Security Group. |
| network_interface_association_ids | Map of Network Interface IDs to their association resource IDs. |
| application_security_group | The full Azure Application Security Group resource object. |

## Usage Examples

### Basic Usage

```hcl
module "application_security_group" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/application-security-group?ref=v0.7.6"

  name                = "asg-web-prod"
  resource_group_name = "rg-workload-prod"
  location            = "eastus"

  tags = {
    Environment = "production"
    Tier        = "web"
  }
}
```

### With Network Interface Association

```hcl
module "application_security_group" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/application-security-group?ref=v0.7.6"

  name                = "asg-backend-prod"
  resource_group_name = "rg-workload-prod"
  location            = "eastus"

  network_interface_ids = [
    azurerm_network_interface.backend_nic.id
  ]

  tags = {
    Environment = "production"
    Tier        = "backend"
  }
}
```

### Referencing in Network Security Group (NSG) Rules

```hcl
module "web_asg" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/application-security-group?ref=v0.7.6"

  name                = "asg-web"
  resource_group_name = "rg-app"
  location            = "eastus"
}

module "db_asg" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/application-security-group?ref=v0.7.6"

  name                = "asg-db"
  resource_group_name = "rg-app"
  location            = "eastus"
}

module "network_security_group" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/network-security-group?ref=v0.7.6"

  name                = "nsg-app"
  resource_group_name = "rg-app"
  location            = "eastus"

  security_rules = [
    {
      name                                       = "allow-web-to-db"
      priority                                   = 100
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "Tcp"
      source_port_range                          = "*"
      destination_port_range                     = "5432"
      source_application_security_group_ids      = [module.web_asg.id]
      destination_application_security_group_ids = [module.db_asg.id]
    }
  ]
}
```
