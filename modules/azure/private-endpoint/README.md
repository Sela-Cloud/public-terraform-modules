# Azure Private Endpoint (Private IP) Terraform Child Module

Terraform module to provision an [Azure Private Endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint).

An Azure Private Endpoint is a network interface that securely connects a Virtual Network (VNet) to an Azure service powered by Azure Private Link (such as Azure Storage, Azure Key Vault, Azure SQL Database) or a customer-owned Private Link Service. It allocates a private IP address from your VNet subnet, keeping traffic on the Microsoft Azure backbone network and eliminating exposure to the public internet.

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
| [azurerm_private_endpoint.endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Private Endpoint. Changing this forces a new resource to be created. | `string` | `"pe-default"` | yes |
| resource_group_name | The name of the Resource Group in which the Private Endpoint should exist. | `string` | `"rg-default"` | yes |
| location | The Azure Region where the Private Endpoint should exist. | `string` | `"eastus"` | yes |
| subnet_id | The ID of the Subnet from which private IP addresses for this Private Endpoint will be allocated. | `string` | n/a | yes |
| custom_network_interface_name | The custom name of the network interface attached to the private endpoint. | `string` | `null` | no |
| private_service_connection | Configuration block for the private service connection to the target Azure resource. | `object` | See below | no |
| private_dns_zone_group | Configuration block for Private DNS Zone Group to automatically manage DNS records. | `object` | `null` | no |
| ip_configurations | List of static IP configuration blocks for assigning specific private IP addresses. | `list(object)` | `[]` | no |
| tags | A mapping of tags which should be assigned to the Private Endpoint. | `map(string)` | `{}` | no |
| timeouts | Custom timeout durations for resource operations. | `object` | `{}` | no |

### `private_service_connection` Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| name | The name of the Private Service Connection. | `string` | `"psc-default"` | yes |
| private_connection_resource_id | The ID of the Azure resource to connect to (e.g. Storage Account, Key Vault). | `string` | `null` | no |
| private_connection_resource_alias | The alias of the Private Link Service to connect to. | `string` | `null` | no |
| subresource_names | A list of subresource names to connect to (e.g. `["blob"]`, `["vault"]`, `["sqlServer"]`). | `list(string)` | `null` | no |
| is_manual_connection | Whether the connection requires manual approval from the resource owner. | `bool` | `false` | no |
| request_message | A message passed to the owner for manual connection requests. | `string` | `null` | no |

### `private_dns_zone_group` Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| name | The name of the Private DNS Zone Group. | `string` | `"default"` | yes |
| private_dns_zone_ids | List of Private DNS Zone resource IDs to associate with this Private Endpoint. | `list(string)` | n/a | yes |

### `ip_configurations` Object List

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| name | The name of the IP configuration. | `string` | n/a | yes |
| private_ip_address | The static private IP address within the subnet to allocate to the Private Endpoint. | `string` | n/a | yes |
| subresource_name | The subresource name this static IP applies to. | `string` | `null` | no |
| member_name | The member name this static IP applies to. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Private Endpoint. |
| name | The Name of the Private Endpoint. |
| resource_group_name | The name of the Resource Group in which the Private Endpoint was created. |
| location | The Azure Region where the Private Endpoint exists. |
| subnet_id | The ID of the Subnet from which the private IP was allocated. |
| network_interface | The network interface objects created by the Private Endpoint, containing `id` and `name`. |
| custom_network_interface_name | The custom network interface name attached to the Private Endpoint. |
| private_dns_zone_configs | The list of private DNS zone configurations associated with the Private Endpoint. |
| private_dns_zone_group | The Private DNS Zone Group block associated with the Private Endpoint. |
| private_service_connection | The Private Service Connection block containing connection status and allocated private IP addresses. |
| ip_configuration | The static IP configuration blocks of the Private Endpoint. |
| tags | The tags assigned to the Private Endpoint. |
| private_endpoint | The full Azure Private Endpoint resource object. |

## Usage Examples

### 1. Basic Private Endpoint with Dynamic Private IP (e.g. Storage Account Blob)

```hcl
module "private_endpoint_storage" {
  source = "../../modules/azure/private-endpoint"

  name                = "pe-storage-blob"
  resource_group_name = "rg-workload-prod"
  location            = "eastus"
  subnet_id           = azurerm_subnet.endpoint_subnet.id

  private_service_connection = {
    name                           = "psc-storage-blob"
    private_connection_resource_id = azurerm_storage_account.example.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### 2. Private Endpoint with Static Private IP Allocation

```hcl
module "private_endpoint_static_ip" {
  source = "../../modules/azure/private-endpoint"

  name                = "pe-keyvault"
  resource_group_name = "rg-workload-prod"
  location            = "eastus"
  subnet_id           = azurerm_subnet.endpoint_subnet.id

  private_service_connection = {
    name                           = "psc-keyvault"
    private_connection_resource_id = azurerm_key_vault.example.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  ip_configurations = [
    {
      name               = "ipconfig-vault"
      private_ip_address = "10.0.2.15"
      subresource_name   = "vault"
      member_name        = "vault"
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

### 3. Private Endpoint with Private DNS Zone Integration

```hcl
module "private_endpoint_dns" {
  source = "../../modules/azure/private-endpoint"

  name                          = "pe-storage-dns"
  resource_group_name           = "rg-workload-prod"
  location                      = "eastus"
  subnet_id                     = azurerm_subnet.endpoint_subnet.id
  custom_network_interface_name = "nic-pe-storage-blob"

  private_service_connection = {
    name                           = "psc-storage-blob"
    private_connection_resource_id = azurerm_storage_account.example.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group = {
    name                 = "dns-zone-group-blob"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }

  tags = {
    Environment = "production"
  }
}
```
