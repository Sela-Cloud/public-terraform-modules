# AWS Network Load Balancer (NLB) Terraform Module

This Terraform module provisions and manages an AWS Network Load Balancer (NLB) along with optional dedicated security groups, target groups, target group attachments, listeners (TCP, UDP, TCP_UDP, TLS), and SSL/TLS certificates (SNI).

## Features

- **Network Load Balancer (`aws_lb`)**:
  - Ultra-high throughput, ultra-low latency Layer 4 load balancing.
  - Internet-facing or internal scheme.
  - Subnet selection across multiple Availability Zones or `subnet_mapping` (with static Elastic IPs or private IPv4/IPv6 addresses).
  - Configurable cross-zone load balancing, deletion protection, client keep-alive, and DNS client routing policy.
  - Optional Security Group integration (supported natively by AWS NLBs).
  - S3 access logging.
- **Target Groups (`aws_lb_target_group`)**:
  - Support for `instance`, `ip`, and `alb` targets.
  - Layer 4 protocols: `TCP`, `UDP`, `TCP_UDP`, and `TLS`.
  - Client IP preservation (`preserve_client_ip`).
  - Proxy Protocol v2 support.
  - TCP and HTTP/HTTPS health checks.
  - Source IP stickiness.
- **Target Group Attachments (`aws_lb_target_group_attachment`)**:
  - Register EC2 instances or IP targets with NLB target groups.
- **Listeners (`aws_lb_listener`)**:
  - `TCP`, `UDP`, `TCP_UDP`, and `TLS` listeners.
  - TLS termination with ACM SSL/TLS certificates and security policies (e.g. `ELBSecurityPolicy-TLS13-1-2-2021-06`).
  - Multi-certificate SNI support via `aws_lb_listener_certificate`.

---

## Architecture

```
                                 Client Traffic (Layer 4)
                                            │
                                            ▼
                  ┌───────────────────────────────────────────────────┐
                  │           AWS Network Load Balancer               │
                  │                 (aws_lb)                          │
                  └─────────┬───────────────────────────────┬─────────┘
                            │                               │
                      Port 80 (TCP)                   Port 443 (TLS)
                            │                               │
                            ▼                               ▼
                  ┌───────────────────┐           ┌───────────────────┐
                  │   TCP Listener    │           │   TLS Listener    │
                  │   (Forward to TG) │           │ (Terminate TLS)   │
                  └─────────┬─────────┘           └─────────┬─────────┘
                            │                               │
                            ▼                               ▼
                  ┌───────────────────┐           ┌───────────────────┐
                  │ TCP Target Group  │           │ TLS Target Group  │
                  └─────────┬─────────┘           └─────────┬─────────┘
                            │                               │
                    ┌───────┴───────┐               ┌───────┴───────┐
                    ▼               ▼               ▼               ▼
              ┌───────────┐   ┌───────────┐   ┌───────────┐   ┌───────────┐
              │ Target 1  │   │ Target 2  │   │ Target 3  │   │ Target 4  │
              └───────────┘   └───────────┘   └───────────┘   └───────────┘
```

---

## Usage Examples

### 1. Basic TCP Network Load Balancer

```hcl
module "nlb" {
  source = "../../modules/aws/network-load-balancer"

  name    = "my-network-lb"
  vpc_id  = "vpc-0123456789abcdef0"
  subnets = ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2"]

  target_groups = {
    tcp_80 = {
      port        = 80
      protocol    = "TCP"
      target_type = "instance"
      health_check = {
        protocol = "TCP"
        interval = 10
        timeout  = 10
      }
    }
  }

  listeners = {
    tcp_80 = {
      port             = 80
      protocol         = "TCP"
      target_group_key = "tcp_80"
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### 2. TLS Termination with ACM Certificate

```hcl
module "nlb" {
  source = "../../modules/aws/network-load-balancer"

  name    = "secure-nlb"
  vpc_id  = "vpc-0123456789abcdef0"
  subnets = ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2"]

  create_security_group = true

  target_groups = {
    backend_tcp = {
      port        = 8080
      protocol    = "TCP"
      target_type = "instance"
      health_check = {
        protocol = "TCP"
      }
    }
  }

  listeners = {
    tls_443 = {
      port             = 443
      protocol         = "TLS"
      certificate_arn  = "arn:aws:acm:us-east-1:123456789012:certificate/abcdef-1234"
      ssl_policy       = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      target_group_key = "backend_tcp"
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
| name | The name of the Network Load Balancer. | `string` | `"network-load-balancer"` | no |
| name_prefix | Unique name prefix (max 6 characters). Conflicts with name. | `string` | `null` | no |
| internal | Whether the load balancer is internal or internet-facing. | `bool` | `false` | no |
| vpc_id | VPC ID for security groups and target groups. | `string` | `null` | no |
| subnets | List of at least two subnet IDs in different AZs. | `list(string)` | `[]` | no |
| subnet_mapping | Subnet mapping definitions for Elastic IP / private IP. | `list(object)` | `[]` | no |
| security_groups | List of existing Security Group IDs. | `list(string)` | `[]` | no |
| create_security_group | Whether to create a dedicated Security Group for the NLB. | `bool` | `false` | no |
| enable_deletion_protection | Protect NLB from deletion. | `bool` | `false` | no |
| enable_cross_zone_load_balancing | Cross-zone load balancing for NLB. | `bool` | `false` | no |
| ip_address_type | IP address type (`ipv4` or `dualstack`). | `string` | `"ipv4"` | no |
| access_logs | Access logs configuration map. | `object` | `null` | no |
| target_groups | Map of target group configurations. | `map(object)` | `{}` | no |
| target_group_attachments | Map of target attachments. | `map(object)` | `{}` | no |
| listeners | Map of listener configurations. | `map(object)` | `{}` | no |
| extra_certificates | Map of extra certificates for TLS SNI. | `map(object)` | `{}` | no |
| tags | Map of tags to apply to resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ARN of the Network Load Balancer. |
| arn | The ARN of the Network Load Balancer. |
| arn_suffix | The ARN suffix for CloudWatch Metrics. |
| dns_name | The DNS name of the NLB. |
| zone_id | Canonical hosted zone ID of the NLB (for Route 53 alias). |
| name | The name of the Network Load Balancer. |
| security_group_id | ID of the dedicated Security Group if created. |
| target_groups | Map of created target groups and their attributes. |
| target_group_arns | List of ARNs of all created target groups. |
| listeners | Map of created listeners and their attributes. |
| tags_all | Map of tags assigned to the NLB. |
