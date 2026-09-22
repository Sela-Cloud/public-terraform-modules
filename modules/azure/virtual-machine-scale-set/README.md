# Azure Virtual Machine Scale Set Terraform Child Module

Terraform module to provision an [Azure Virtual Machine Scale Set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set).

Azure Virtual Machine Scale Sets let you create and manage a group of load-balanced VMs. The number of VM instances can automatically increase or decrease in response to demand or a defined schedule. Scale sets provide high availability to your applications and allow you to centrally manage, configure, and update a large number of VMs.

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
| [azurerm_virtual_machine_scale_set.vmss](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Virtual Machine Scale Set. | `string` | `"vmss-default"` | yes |
| resource_group_name | The name of the Resource Group in which to create the Scale Set. | `string` | `"rg-default"` | yes |
| location | The Azure Region where the Virtual Machine Scale Set should exist. | `string` | `"eastus"` | yes |
| sku | SKU sizing and instance capacity. | `object` | See below | no |
| upgrade_policy_mode | Upgrade policy mode (`Manual`, `Rolling`, `Automatic`). | `string` | `"Manual"` | no |
| automatic_os_upgrade | Whether automatic OS patches are applied by Azure. | `bool` | `false` | no |
| health_probe_id | Load balancer health probe ID (required for `Rolling` upgrades). | `string` | `null` | no |
| rolling_upgrade_policy | Rolling upgrade policy configuration. | `object` | `null` | no |
| overprovision | Whether scale set instances should be overprovisioned. | `bool` | `true` | no |
| single_placement_group | Whether limited to a single placement group (max 100 VMs). | `bool` | `true` | no |
| priority | Priority of the scale set (`Regular` or `Low`). | `string` | `"Regular"` | no |
| eviction_policy | Eviction policy when priority is `Low` (`Deallocate` or `Delete`). | `string` | `null` | no |
| zones | Collection of availability zones to spread VMs over. | `list(string)` | `null` | no |
| proximity_placement_group_id | Proximity Placement Group ID. | `string` | `null` | no |
| license_type | License type for Windows machines (`Windows_Client` or `Windows_Server`). | `string` | `null` | no |
| storage_profile_os_disk | OS disk configuration profile. | `object` | See below | no |
| storage_profile_image_reference | Marketplace or custom image reference. | `object` | See below | no |
| storage_profile_data_disks | List of data disks attached to scale set instances. | `list(object)` | `[]` | no |
| os_profile | Operating system profile settings. | `object` | See below | no |
| os_profile_linux_config | Linux OS configuration (SSH keys, password auth). | `object` | `null` | no |
| os_profile_windows_config | Windows OS configuration. | `object` | `null` | no |
| network_profiles | List of network profile configurations. | `list(object)` | n/a | yes |
| identity | Managed Service Identity configuration. | `object` | `null` | no |
| boot_diagnostics | Boot diagnostics configuration. | `object` | `null` | no |
| extensions | List of scale set extension profiles. | `list(object)` | `[]` | no |
| tags | A mapping of tags assigned to the resource. | `map(string)` | `{}` | no |
| timeouts | Custom timeout durations. | `object` | `{}` | no |

### `sku` Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| name | Virtual machine instance size. | `string` | `"Standard_B2s"` | yes |
| tier | SKU tier (`Standard` or `Basic`). | `string` | `"Standard"` | no |
| capacity | Number of virtual machine instances in the scale set. | `number` | `2` | yes |

### `storage_profile_os_disk` Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| name | OS disk name. | `string` | `null` | no |
| caching | Caching type (`None`, `ReadOnly`, `ReadWrite`). | `string` | `"ReadWrite"` | no |
| create_option | Creation option (`FromImage`). | `string` | `"FromImage"` | no |
| managed_disk_type | Managed disk type (`Standard_LRS`, `StandardSSD_LRS`, `Premium_LRS`). | `string` | `"Standard_LRS"` | no |
| disk_size_gb | Custom disk size in GB. | `number` | `null` | no |
| os_type | Operating system type (`Linux`, `Windows`). | `string` | `null` | no |
| image | Custom image blob URI. | `string` | `null` | no |
| vhd_containers | List of VHD storage container URIs for unmanaged disks. | `list(string)` | `null` | no |

### `storage_profile_image_reference` Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| publisher | Image publisher. | `string` | `"Canonical"` | no |
| offer | Image offer. | `string` | `"0001-com-ubuntu-server-jammy"` | no |
| sku | Image SKU. | `string` | `"22_04-lts"` | no |
| version | Image version. | `string` | `"latest"` | no |
| id | Custom image resource ID. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The Virtual Machine Scale Set ID. |
| name | The Name of the Virtual Machine Scale Set. |
| resource_group_name | The name of the Resource Group in which the Scale Set was created. |
| location | The Azure Region where the Scale Set exists. |
| sku | The SKU specification and capacity of the Virtual Machine Scale Set. |
| identity | The Managed Service Identity block associated with the Scale Set. |
| network_profile | The Network Profile block configured on the Virtual Machine Scale Set. |
| virtual_machine_scale_set | The full Azure Virtual Machine Scale Set resource object. |

## Usage Examples

### 1. Basic Linux Scale Set with Load Balancer Integration

```hcl
module "vm_scale_set" {
  source = "../../modules/azure/virtual-machine-scale-set"

  name                = "vmss-web-prod"
  resource_group_name = "rg-compute-prod"
  location            = "eastus"

  sku = {
    name     = "Standard_D2s_v5"
    tier     = "Standard"
    capacity = 3
  }

  upgrade_policy_mode = "Manual"

  os_profile = {
    computer_name_prefix = "webvm"
    admin_username       = "azureuser"
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

  network_profiles = [
    {
      name    = "nic-profile"
      primary = true
      ip_configurations = [
        {
          name                                   = "ipconfig-primary"
          primary                                = true
          subnet_id                              = azurerm_subnet.app.id
          load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.web.id]
        }
      ]
    }
  ]

  tags = {
    Environment = "production"
    Tier        = "frontend"
  }
}
```

### 2. Scale Set with Rolling Upgrades and Health Probe

```hcl
module "vm_scale_set_rolling" {
  source = "../../modules/azure/virtual-machine-scale-set"

  name                = "vmss-api-prod"
  resource_group_name = "rg-compute-prod"
  location            = "eastus"

  sku = {
    name     = "Standard_D4s_v5"
    capacity = 5
  }

  upgrade_policy_mode  = "Rolling"
  automatic_os_upgrade = true
  health_probe_id      = azurerm_lb_probe.api_health.id

  rolling_upgrade_policy = {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 5
    pause_time_between_batches              = "PT1M"
  }

  network_profiles = [
    {
      name    = "nic-profile"
      primary = true
      ip_configurations = [
        {
          name      = "ipconfig1"
          primary   = true
          subnet_id = azurerm_subnet.api.id
        }
      ]
    }
  ]

  identity = {
    type = "SystemAssigned"
  }
}
```
