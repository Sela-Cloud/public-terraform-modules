# Azure Virtual Machine Terraform Child Module

Terraform module to provision an [Azure Virtual Machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine).

This module manages the Azure Virtual Machine resource with support for managed OS disks, attached data disks, custom/marketplace images, Linux and Windows OS profiles, Managed Service Identity (MSI), boot diagnostics, and availability sets/zones.

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
| [azurerm_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Virtual Machine. | `string` | — | yes |
| resource_group_name | The name of the Resource Group in which to create the Virtual Machine. | `string` | — | yes |
| location | The Azure Region where the Virtual Machine exists. | `string` | — | yes |
| network_interface_ids | List of Network Interface IDs associated with this Virtual Machine. | `list(string)` | — | yes |
| vm_size | The size/SKU of the Virtual Machine. | `string` | `"Standard_B2s"` | no |
| primary_network_interface_id | The ID of the primary Network Interface. | `string` | `null` | no |
| availability_set_id | The ID of the Availability Set in which the VM should exist. | `string` | `null` | no |
| zones | List containing the Availability Zone for the VM. | `list(string)` | `null` | no |
| proximity_placement_group_id | The ID of the Proximity Placement Group. | `string` | `null` | no |
| license_type | BYOL License type (`Windows_Client` or `Windows_Server`). | `string` | `null` | no |
| delete_os_disk_on_termination | Delete OS disk when the Virtual Machine is destroyed. | `bool` | `true` | no |
| delete_data_disks_on_termination | Delete data disks when the Virtual Machine is destroyed. | `bool` | `false` | no |
| storage_os_disk | Configuration for the OS Disk. | `object` | *(Ubuntu/Standard_LRS defaults)* | no |
| storage_image_reference | Image reference configuration. | `object` | *(Ubuntu 22.04 LTS defaults)* | no |
| storage_data_disks | List of storage data disks to attach. | `list(object)` | `[]` | no |
| os_profile | Operating system profile settings. | `object` | `null` | no |
| os_profile_linux_config | Linux-specific settings (SSH keys, password auth). | `object` | `null` | no |
| os_profile_windows_config | Windows-specific settings (agent, auto-upgrades). | `object` | `null` | no |
| identity | Managed Identity configuration (`SystemAssigned`, `UserAssigned`). | `object` | `null` | no |
| boot_diagnostics | Boot diagnostics configuration. | `object` | `null` | no |
| tags | Key-value tags to assign to the Virtual Machine. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Virtual Machine. |
| name | The Name of the Virtual Machine. |
| resource_group_name | The name of the Resource Group in which the Virtual Machine was created. |
| location | The Azure Region of the Virtual Machine. |
| vm_size | The size/SKU of the Virtual Machine. |
| network_interface_ids | The list of Network Interface IDs attached to the Virtual Machine. |
| identity | The Managed Service Identity configuration of the Virtual Machine. |
| virtual_machine | The full Azure Virtual Machine resource object. |

## Usage Examples

### Linux Virtual Machine with SSH Key

```hcl
module "virtual_machine" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/virtual-machine?ref=v0.7.6"

  name                  = "vm-app-prod"
  resource_group_name   = "rg-compute-prod"
  location              = "eastus"
  vm_size               = "Standard_B2s"
  network_interface_ids = ["/subscriptions/.../networkInterfaces/nic-app-prod"]

  os_profile = {
    computer_name  = "vm-app-prod"
    admin_username = "azureuser"
  }

  os_profile_linux_config = {
    disable_password_authentication = true
    ssh_keys = [
      {
        path     = "/home/azureuser/.ssh/authorized_keys"
        key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."
      }
    ]
  }

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### Windows Virtual Machine with Managed Identity

```hcl
module "virtual_machine" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/virtual-machine?ref=v0.7.6"

  name                  = "vm-win-prod"
  resource_group_name   = "rg-compute-prod"
  location              = "eastus"
  vm_size               = "Standard_D2s_v3"
  network_interface_ids = ["/subscriptions/.../networkInterfaces/nic-win-prod"]

  storage_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  os_profile = {
    computer_name  = "vm-win-prod"
    admin_username = "azureadmin"
    admin_password = "P@ssw0rd1234!"
  }

  os_profile_windows_config = {
    provision_vm_agent        = true
    enable_automatic_upgrades = true
  }

  identity = {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "production"
    Workload    = "windows"
  }
}
```
