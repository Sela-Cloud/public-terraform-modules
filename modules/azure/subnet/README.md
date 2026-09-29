# Azure Subnet Terraform Module

Terraform module to create and manage an Azure Subnet within a Virtual Network.

## Features

- Configures Subnet with CIDR address prefixes within an existing Virtual Network.
- Supports Service Endpoints and Service Endpoint Policy associations.
- Supports Private Endpoint and Private Link Service Network Policies.
- Supports Subnet Delegation for dedicated Azure PaaS services (e.g. App Service, Container Instances).

## Usage

```hcl
module "subnet" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/subnet?ref=v0.8.3"

  name                 = "snet-workload-prod"
  resource_group_name  = "rg-network-prod"
  virtual_network_name = "vnet-hub-prod"
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
}
```

## Inputs

| Name | Description | Type | Required | Default |
|:-----|:------------|:-----|:--------:|:--------|
| `name` | Subnet name | `string` | Yes | - |
| `resource_group_name` | Resource Group name | `string` | Yes | - |
| `virtual_network_name` | Virtual Network name | `string` | Yes | - |
| `address_prefixes` | Subnet CIDR ranges | `list(string)` | Yes | - |
| `service_endpoints` | List of Service Endpoints | `list(string)` | No | `[]` |
| `service_endpoint_policy_ids` | Service Endpoint Policy IDs | `list(string)` | No | `[]` |
| `private_endpoint_network_policies` | Private Endpoint Network Policies (`Disabled`, `Enabled`, `NetworkSecurityGroupEnabled`, `RouteTableEnabled`) | `string` | No | `"Disabled"` |
| `private_link_service_network_policies_enabled` | Private Link Service Network Policies enabled | `bool` | No | `false` |
| `delegation` | Subnet delegation object | `object` | No | `null` |

## Outputs

| Name | Description |
|:-----|:------------|
| `id` | The ID of the Subnet |
| `name` | The Name of the Subnet |
| `resource_group_name` | The Resource Group in which the Subnet exists |
| `virtual_network_name` | The Virtual Network associated with the Subnet |
| `address_prefixes` | The Address Prefixes of the Subnet |
| `subnet` | The complete Azure Subnet resource object |
