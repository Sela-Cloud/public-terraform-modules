# Azure DNS Zone Terraform Child Module

Terraform module to provision an [Azure DNS Zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone).

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
| [azurerm_dns_zone.dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the DNS Zone. Must be a valid domain name. Changing this forces a new resource to be created. | `string` | `"example.com"` | no |
| resource_group_name | The name of the Resource Group in which to create the DNS Zone. Changing this forces a new resource to be created. | `string` | `"rg-default"` | no |
| soa_record | Customize details relating to the Start of Authority (SOA) record of the DNS Zone. | <pre>object({<br>  email         = string<br>  host_name     = optional(string, null)<br>  expire_time   = optional(number, 2419200)<br>  minimum_ttl   = optional(number, 300)<br>  refresh_time  = optional(number, 3600)<br>  retry_time    = optional(number, 300)<br>  serial_number = optional(number, 1)<br>  ttl           = optional(number, 3600)<br>  tags          = optional(map(string), {})<br>})</pre> | `null` | no |
| tags | A mapping of tags which should be assigned to the DNS Zone. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the DNS Zone. |
| name | The Name of the DNS Zone. |
| resource_group_name | The Name of the Resource Group in which the DNS Zone exists. |
| name_servers | A list of values that make up the NS record for the DNS Zone. |
| number_of_record_sets | The number of records already in the DNS Zone. |
| max_number_of_record_sets | The maximum number of records that can be created in the DNS Zone. |
| tags | The tags assigned to the DNS Zone. |
| dns_zone | The full Azure DNS Zone resource object. |

## Usage

### Basic DNS Zone

```hcl
module "dns_zone" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/dns-zone?ref=v0.7.6"

  name                = "mydomain.com"
  resource_group_name = "rg-dns-prod"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### DNS Zone with Custom SOA Record

```hcl
module "dns_zone" {
  source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/dns-zone?ref=v0.7.6"

  name                = "mydomain.com"
  resource_group_name = "rg-dns-prod"

  soa_record = {
    email        = "hostmaster.mydomain.com"
    expire_time  = 2419200
    minimum_ttl  = 300
    refresh_time = 3600
    retry_time   = 300
    ttl          = 3600
    tags = {
      Owner = "dns-admin"
    }
  }

  tags = {
    Environment = "production"
  }
}
```
