# AWS VPC Endpoint Terraform Module

This generic Terraform module provisions and manages Amazon Virtual Private Cloud (VPC) Endpoints, supporting both **Gateway Endpoints** (S3, DynamoDB) and **Interface Endpoints** (AWS PrivateLink for EC2, ECR, SSM, Secrets Manager, CloudWatch Logs, etc.), along with dedicated security groups and route table associations.

## Features

- **Multi-Endpoint Provisioning**:
  - Deploy multiple Interface or Gateway endpoints in a single module call.
  - Smart service resolution: specify short service names (`s3`, `dynamodb`, `ecr.api`, `ssm`) or fully qualified names (`com.amazonaws.<region>.<service>`).
- **Gateway Endpoints (`vpc_endpoint_type = "Gateway"`)**:
  - Zero-cost, high-throughput private access to Amazon S3 and Amazon DynamoDB.
  - Automatic association with VPC route tables.
  - Exports `prefix_list_id` and `cidr_blocks` for easy referencing in security groups and route tables.
- **Interface Endpoints (`vpc_endpoint_type = "Interface"`)**:
  - AWS PrivateLink network interfaces (ENIs) placed in specified subnets.
  - Private DNS integration (`private_dns_enabled`) for seamless application connectivity without changing endpoint URLs.
  - IPv4 and Dual-stack addressing support.
- **Dedicated Security Group**:
  - Optional built-in security group for Interface endpoints with configurable HTTPS (443) ingress rules.
- **Endpoint Policy**:
  - Attach custom IAM resource policies to restrict access to specific accounts, buckets, or actions.

---

## Architecture

```
                                  AWS VPC (vpc_id)
                                         │
        ┌────────────────────────────────┴────────────────────────────────┐
        ▼                                                                 ▼
┌────────────────────────────────┐                              ┌────────────────────────────────┐
│       Gateway Endpoints        │                              │      Interface Endpoints       │
│      (S3, DynamoDB, etc.)      │                              │      (PrivateLink ENIs)        │
├────────────────────────────────┤                              ├────────────────────────────────┤
│ • Attaches to Route Tables     │                              │ • Attaches to Subnets          │
│ • No ENIs or IP addresses      │                              │ • Private IP per AZ            │
│ • Zero hourly cost             │                              │ • Security Group Protected     │
│ • Direct S3 / DynamoDB access  │                              │ • Private DNS Resolution       │
└────────────────────────────────┘                              └────────────────────────────────┘
```

---

## Usage Examples

### 1. S3 Gateway Endpoint and SSM / ECR Interface Endpoints

```hcl
module "vpc_endpoints" {
  source = "../../modules/aws/vpc-endpoint"

  vpc_id          = "vpc-0123456789abcdef0"
  subnet_ids      = ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2"]
  route_table_ids = ["rtb-0123456789abcdef0"]

  create_security_group = true

  endpoints = {
    # Gateway endpoint for S3
    s3 = {
      service      = "s3"
      service_type = "Gateway"
    }

    # Interface endpoint for Systems Manager
    ssm = {
      service      = "ssm"
      service_type = "Interface"
    }

    # Interface endpoint for ECR API
    ecr_api = {
      service      = "ecr.api"
      service_type = "Interface"
    }

    # Interface endpoint for ECR DKR
    ecr_dkr = {
      service      = "ecr.dkr"
      service_type = "Interface"
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### 2. S3 and DynamoDB Gateway Endpoints Only

```hcl
module "gateway_endpoints" {
  source = "../../modules/aws/vpc-endpoint"

  vpc_id          = "vpc-0123456789abcdef0"
  route_table_ids = ["rtb-0123456789abcdef0"]

  endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"
    }
    dynamodb = {
      service      = "dynamodb"
      service_type = "Gateway"
    }
  }
}
```

---

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_id | The ID of the VPC. If null, falls back to default VPC. | `string` | `null` | no |
| subnet_ids | Default subnets for Interface endpoints. | `list(string)` | `[]` | no |
| route_table_ids | Default route tables for Gateway endpoints. | `list(string)` | `[]` | no |
| security_group_ids | Default security groups for Interface endpoints. | `list(string)` | `[]` | no |
| create_security_group | Whether to create a dedicated Security Group for Interface endpoints. | `bool` | `false` | no |
| security_group_name | Name of dedicated security group. | `string` | `null` | no |
| endpoints | Map of endpoint definitions to create. | `map(object)` | `{}` | no |
| tags | Map of tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| endpoints | Map of created endpoints with IDs, ARNs, DNS entries, and ENIs. |
| endpoint_ids | Map of endpoint keys to their generated VPC Endpoint IDs. |
| security_group_id | ID of the dedicated Security Group if created. |
| security_group_arn | ARN of the dedicated Security Group if created. |
