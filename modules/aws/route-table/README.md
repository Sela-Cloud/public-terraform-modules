# AWS Route Table Terraform Module

This generic Terraform module provisions Amazon Virtual Private Cloud (VPC) Route Tables, standalone Routes (`aws_route`), and Route Table Associations (`aws_route_table_association`) for subnets and gateways.

It supports multiple route tables, dynamic associations, and all route target types supported by the current AWS Terraform provider without hardcoding any network details or customer-specific identifiers.

## Features

- **Multiple Route Tables**: Provision and manage any number of route tables within a single module invocation.
- **Standalone Routes**: Uses dedicated `aws_route` resources instead of legacy inline route blocks to eliminate resource conflicts and state drift.
- **Automatic Local Route Safety**: Does not touch or overwrite the default VPC local route, which AWS manages automatically.
- **Multi-Target Routing**: Supports all modern AWS routing destinations and targets:
  - **Destinations**: IPv4 CIDRs (`destination_cidr_block`), IPv6 CIDRs (`destination_ipv6_cidr_block`), and AWS Managed Prefix Lists (`destination_prefix_list_id`).
  - **Targets**: Internet Gateways (`gateway_id`), NAT Gateways (`nat_gateway_id`), VPC Peering Connections (`vpc_peering_connection_id`), Transit Gateways (`transit_gateway_id`), Virtual Private Gateways (`gateway_id`), Network Interfaces / ENIs (`network_interface_id`), Gateway VPC Endpoints (`vpc_endpoint_id`), Egress-Only Internet Gateways (`egress_only_gateway_id`), Carrier Gateways (`carrier_gateway_id`), Local Gateways (`local_gateway_id`), and Cloud WAN Core Networks (`core_network_arn`).
- **Flexible Associations**:
  - Subnet associations with automatic uniqueness validation to avoid AWS `Resource.AlreadyAssociated` errors.
  - Gateway / Edge associations for ingress routing and traffic inspection with Internet Gateways or Virtual Private Gateways.
- **Strict Input Validation**: Validates that each route supplies exactly one destination and exactly one target, and that each route within a table targets a unique destination.
- **Stable Resource Keys**: Uses composite keys (`<route_table_key>.<route_key>` and `<route_table_key>.<subnet_id>`) for `for_each` mapping, ensuring drift-free and index-independent updates.

---

## Architecture

```
                       ┌──────────────────────────────┐
                       │     AWS VPC (vpc_id)         │
                       └──────────────┬───────────────┘
                                      │
            ┌─────────────────────────┴─────────────────────────┐
            ▼                                                   ▼
┌───────────────────────┐                           ┌───────────────────────┐
│  Public Route Table   │                           │  Private Route Table  │
└───────────┬───────────┘                           └───────────┬───────────┘
            │                                                   │
  ┌─────────┴─────────┐                               ┌─────────┴─────────┐
  ▼                   ▼                               ▼                   ▼
┌──────────────┐    ┌──────────────┐                ┌──────────────┐    ┌──────────────┐
│ Route (IGW)  │    │ Subnet Assoc │                │ Route (NAT)  │    │ Subnet Assoc │
│ 0.0.0.0/0    │    │ (Public A/B) │                │ 0.0.0.0/0    │    │ (Private A/B)│
└──────────────┘    └──────────────┘                └──────────────┘    └──────────────┘
```

---

## Usage Examples

> [!NOTE]
> All resource IDs (e.g. `vpc-0123456789abcdef0`, `subnet-0123456789abcdef0`, `igw-0123456789abcdef0`) used in these examples are fictional and provided for illustrative purposes only.

### 1. Public Route Table with Internet Gateway

```hcl
module "public_route_table" {
  source = "../../modules/aws/route-table"

  vpc_id = "vpc-0123456789abcdef0"

  route_tables = {
    public = {
      name    = "prod-public-rt"
      subnets = [
        "subnet-0123456789abcdef0",
        "subnet-0123456789abcdef1"
      ]
      routes = {
        ipv4_default = {
          destination_cidr_block = "0.0.0.0/0"
          gateway_id             = "igw-0123456789abcdef0"
        }
        ipv6_default = {
          destination_ipv6_cidr_block = "::/0"
          gateway_id                  = "igw-0123456789abcdef0"
        }
      }
      tags = {
        Tier = "public"
      }
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### 2. Private Route Table with NAT Gateway

```hcl
module "private_route_table" {
  source = "../../modules/aws/route-table"

  vpc_id = "vpc-0123456789abcdef0"

  route_tables = {
    private = {
      name    = "prod-private-rt"
      subnets = [
        "subnet-0123456789abcdef2",
        "subnet-0123456789abcdef3"
      ]
      routes = {
        default_nat = {
          destination_cidr_block = "0.0.0.0/0"
          nat_gateway_id         = "nat-0123456789abcdef0"
        }
      }
      tags = {
        Tier = "private"
      }
    }
  }
}
```

### 3. VPC Peering Connection Route

```hcl
module "peering_routes" {
  source = "../../modules/aws/route-table"

  vpc_id = "vpc-0123456789abcdef0"

  route_tables = {
    app = {
      name    = "app-tier-rt"
      subnets = ["subnet-0123456789abcdef4"]
      routes = {
        peer_vpc = {
          destination_cidr_block    = "172.16.0.0/16"
          vpc_peering_connection_id = "pcx-0123456789abcdef0"
        }
      }
    }
  }
}
```

### 4. Multi-Tier Setup (Public, Private & Database Subnets)

```hcl
module "network_routing" {
  source = "../../modules/aws/route-table"

  vpc_id = "vpc-0123456789abcdef0"

  route_tables = {
    # Public tier routing to Internet Gateway
    public = {
      name    = "prod-public-rt"
      subnets = [
        "subnet-0123456789abcdef0",
        "subnet-0123456789abcdef1"
      ]
      routes = {
        internet = {
          destination_cidr_block = "0.0.0.0/0"
          gateway_id             = "igw-0123456789abcdef0"
        }
      }
    }

    # Private application tier routing to NAT Gateway and Corporate Transit Gateway
    private = {
      name    = "prod-private-rt"
      subnets = [
        "subnet-0123456789abcdef2",
        "subnet-0123456789abcdef3"
      ]
      routes = {
        nat = {
          destination_cidr_block = "0.0.0.0/0"
          nat_gateway_id         = "nat-0123456789abcdef0"
        }
        corp_network = {
          destination_cidr_block = "10.100.0.0/16"
          transit_gateway_id     = "tgw-0123456789abcdef0"
        }
        s3_prefix_list = {
          destination_prefix_list_id = "pl-63a5400a"
          vpc_endpoint_id            = "vpce-0123456789abcdef0"
        }
      }
    }

    # Isolated database tier with no default outbound route (VPC local only)
    database = {
      name    = "prod-database-rt"
      subnets = [
        "subnet-0123456789abcdef4",
        "subnet-0123456789abcdef5"
      ]
      routes = {}
      tags = {
        Tier = "isolated-database"
      }
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### 5. Edge / Ingress Route Table (Gateway Association)

For firewall inspection patterns where incoming traffic from an Internet Gateway is routed through an inspection ENI:

```hcl
module "edge_route_table" {
  source = "../../modules/aws/route-table"

  vpc_id = "vpc-0123456789abcdef0"

  route_tables = {
    igw_ingress = {
      name       = "igw-ingress-rt"
      gateway_id = "igw-0123456789abcdef0"
      routes = {
        inspect_subnets = {
          destination_cidr_block = "10.0.1.0/24"
          network_interface_id   = "eni-0123456789abcdef0"
        }
      }
      tags = {
        Role = "edge-inspection"
      }
    }
  }
}
```

---

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Default VPC ID to apply to all route tables unless overridden at the individual route table level. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to all resources created by this module. | `map(string)` | `{}` | no |
| <a name="input_route_tables"></a> [route\_tables](#input\_route\_tables) | Map of route table configurations to create, keyed by route table identifier. | <pre>map(object({<br>  name             = optional(string, null)<br>  vpc_id           = optional(string, null)<br>  propagating_vgws = optional(list(string), [])<br>  subnets          = optional(list(string), [])<br>  gateway_id       = optional(string, null)<br>  routes = optional(map(object({<br>    destination_cidr_block      = optional(string, null)<br>    destination_ipv6_cidr_block = optional(string, null)<br>    destination_prefix_list_id  = optional(string, null)<br>    carrier_gateway_id          = optional(string, null)<br>    core_network_arn            = optional(string, null)<br>    egress_only_gateway_id      = optional(string, null)<br>    gateway_id                  = optional(string, null)<br>    local_gateway_id            = optional(string, null)<br>    nat_gateway_id              = optional(string, null)<br>    network_interface_id        = optional(string, null)<br>    transit_gateway_id          = optional(string, null)<br>    vpc_endpoint_id             = optional(string, null)<br>    vpc_peering_connection_id   = optional(string, null)<br>    timeouts = optional(object({<br>      create = optional(string, null)<br>      delete = optional(string, null)<br>    }), null)<br>  })), {})<br>  tags = optional(map(string), {})<br>}))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_route_tables"></a> [route\_tables](#output\_route\_tables) | Map of all created `aws_route_table` resources keyed by route table identifier. |
| <a name="output_route_table_ids"></a> [route\_table\_ids](#output\_route\_table\_ids) | Map of route table identifiers to their corresponding route table IDs. |
| <a name="output_route_table_arns"></a> [route\_table\_arns](#output\_route\_table\_arns) | Map of route table identifiers to their corresponding route table ARNs. |
| <a name="output_subnet_associations"></a> [subnet\_associations](#output\_subnet\_associations) | Map of created `aws_route_table_association` resources for subnets, keyed by `<route_table_key>.<subnet_id>`. |
| <a name="output_subnet_association_ids"></a> [subnet\_association\_ids](#output\_subnet\_association\_ids) | Map of `<route_table_key>.<subnet_id>` to their corresponding association IDs. |
| <a name="output_subnet_association_ids_by_route_table"></a> [subnet\_association\_ids\_by\_route\_table](#output\_subnet\_association\_ids\_by\_route\_table) | Map of route table identifiers to lists of subnet association IDs. |
| <a name="output_gateway_associations"></a> [gateway\_associations](#output\_gateway\_associations) | Map of created `aws_route_table_association` resources for gateways, keyed by route table identifier. |
| <a name="output_gateway_association_ids"></a> [gateway\_association\_ids](#output\_gateway\_association\_ids) | Map of route table identifiers to their corresponding gateway association IDs. |
| <a name="output_routes"></a> [routes](#output\_routes) | Map of all created `aws_route` resources, keyed by `<route_table_key>.<route_key>`. |
| <a name="output_route_ids"></a> [route\_ids](#output\_route\_ids) | Map of `<route_table_key>.<route_key>` to their corresponding route IDs. |
| <a name="output_route_ids_by_route_table"></a> [route\_ids\_by\_route\_table](#output\_route\_ids\_by\_route\_table) | Map of route table identifiers to lists of route IDs. |
