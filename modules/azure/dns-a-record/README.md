# Azure DNS A Record Terraform Child Module

Terraform module to provision an [Azure DNS A Record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record.html).

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
| [azurerm_dns_a_record.dns_a_record](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the DNS A Record. Relative to the zone name, or '@' for the zone apex. Changing this forces a new resource to be created. | `string` | `"@"` | no |
| resource_group_name | The name of the Resource Group in which to create the DNS A Record. Changing this forces a new resource to be created. | `string` | `"rg-default"` | no |
| zone_name | The name of the DNS Zone in which to create the DNS A Record. Changing this forces a new resource to be created. | `string` | `"example.com"` | no |
| ttl | The Time To Live (TTL) of the DNS record in seconds. | `number` | `300` | no |
| records | List of IPv4 Addresses for this A record. Mutually exclusive with `target_resource_id`. | `list(string)` | `["10.0.0.1"]` | no |
| target_resource_id | The Azure resource ID of the target object (e.g. Public IP) to create an alias record. Mutually exclusive with `records`. | `string` | `null` | no |
| tags | A mapping of tags which should be assigned to the DNS A Record. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the DNS A Record. |
| name | The Name of the DNS A Record. |
| resource_group_name | The Name of the Resource Group in which the DNS A Record exists. |
| zone_name | The Name of the DNS Zone in which the DNS A Record exists. |
| fqdn | The FQDN of the DNS A Record. |
| ttl | The Time To Live of the DNS A Record. |
| records | The list of IPv4 addresses assigned to the DNS A Record. |
| target_resource_id | The target resource ID if the record is configured as an alias. |
| tags | The tags assigned to the DNS A Record. |
| dns_a_record | The full Azure DNS A Record resource object. |

## Usage

### Standard DNS A Record

```hcl
module "dns_a_record" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/dns-a-record?ref=v0.7.6"

  name                = "www"
  resource_group_name = "rg-dns-prod"
  zone_name           = "mydomain.com"
  ttl                 = 300
  records             = ["20.10.10.10"]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### Alias Record (e.g. Pointing to Azure Public IP)

```hcl
module "dns_a_record_alias" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/dns-a-record?ref=v0.7.6"

  name                = "@"
  resource_group_name = "rg-dns-prod"
  zone_name           = "mydomain.com"
  ttl                 = 300
  target_resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-net/providers/Microsoft.Network/publicIPAddresses/pip-web"

  tags = {
    Environment = "production"
  }
}
```
