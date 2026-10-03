# AWS Application Load Balancer (ALB) Terraform Module

This Terraform module provisions and manages an AWS Application Load Balancer (ALB) along with optional dedicated security groups, target groups, target group attachments, listeners, routing rules, SSL/TLS certificates (SNI), and AWS WAF association.

## Features

- **Application Load Balancer (`aws_lb`)**:
  - Internet-facing or internal load balancing.
  - Subnet selection across multiple Availability Zones or advanced `subnet_mapping` (with Elastic IPs or static private IPs).
  - Configurable idle timeout, deletion protection, HTTP/2, cross-zone load balancing, and header preservation.
  - S3 access logs and connection logs integration.
- **Dedicated Security Group (`aws_security_group`)**:
  - Optional built-in security group with default ingress on HTTP (80) and HTTPS (443).
  - Custom ingress and egress rules.
- **Target Groups (`aws_lb_target_group`)**:
  - Support for `instance`, `ip`, `lambda`, and `alb` targets.
  - Granular health checks (path, protocol, interval, timeout, healthy/unhealthy thresholds, HTTP matchers).
  - Stickiness configurations (load balancer cookies or application cookies).
  - Slow start and deregistration delays.
- **Target Group Attachments (`aws_lb_target_group_attachment`)**:
  - Register EC2 instances, IP addresses, or Lambdas with target groups directly within the module.
- **Listeners (`aws_lb_listener`)**:
  - HTTP and HTTPS protocol support.
  - Configurable SSL policies (e.g. `ELBSecurityPolicy-TLS13-1-2-2021-06`).
  - Actions: forward to target groups, HTTP to HTTPS redirect (`HTTP_301`), or fixed custom JSON/HTML response.
  - Multi-certificate SNI support via `aws_lb_listener_certificate`.
- **Listener Rules (`aws_lb_listener_rule`)**:
  - Path-based routing (`/api/*`, `/app/*`).
  - Host-based routing (`api.example.com`, `app.example.com`).
  - HTTP header, HTTP request method, query string, and source IP conditions.
- **AWS WAF Integration**:
  - Seamless association with AWS WAFv2 Web ACL.

---

## Architecture

```
                                 Client Requests
                                        │
                                        ▼
                  ┌───────────────────────────────────────────┐
                  │      AWS Application Load Balancer        │
                  │              (aws_lb)                     │
                  └───────┬───────────────────────────┬───────┘
                          │                           │
                   Port 80 (HTTP)             Port 443 (HTTPS)
                          │                           │
                          ▼                           ▼
                  ┌───────────────┐           ┌───────────────┐
                  │ HTTP Listener │           │ HTTPS Listener│
                  │ (Redirect 301)│           │ (Forward Rule)│
                  └───────────────┘           └───────┬───────┘
                                                      │
                                                      ▼
                                       ┌─────────────────────────────┐
                                       │     Target Group (TG)       │
                                       │    (Health Check: /health)  │
                                       └──────────────┬──────────────┘
                                                      │
                                          ┌───────────┴───────────┐
                                          ▼                       ▼
                                   ┌──────────────┐        ┌──────────────┐
                                   │ EC2 Target 1 │        │ EC2 Target 2 │
                                   └──────────────┘        └──────────────┘
```

---

## Usage Examples

### 1. Simple HTTP Application Load Balancer

```hcl
module "alb" {
  source = "../../modules/aws/application-load-balancer"

  name    = "my-web-alb"
  vpc_id  = "vpc-0123456789abcdef0"
  subnets = ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2"]

  create_security_group = true

  target_groups = {
    web = {
      port        = 80
      protocol    = "HTTP"
      target_type = "instance"
      health_check = {
        path    = "/healthz"
        matcher = "200"
      }
    }
  }

  listeners = {
    http = {
      port             = 80
      protocol         = "HTTP"
      target_group_key = "web"
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### 2. HTTPS with Automatic HTTP-to-HTTPS Redirect and ACM Certificate

```hcl
module "alb" {
  source = "../../modules/aws/application-load-balancer"

  name    = "secure-web-alb"
  vpc_id  = "vpc-0123456789abcdef0"
  subnets = ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2"]

  create_security_group = true

  target_groups = {
    app = {
      port        = 8080
      protocol    = "HTTP"
      target_type = "instance"
      health_check = {
        path                = "/"
        interval            = 15
        timeout             = 3
        healthy_threshold   = 2
        unhealthy_threshold = 2
        matcher             = "200"
      }
    }
  }

  listeners = {
    http = {
      port                = 80
      protocol            = "HTTP"
      default_action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    https = {
      port             = 443
      protocol         = "HTTPS"
      certificate_arn  = "arn:aws:acm:us-east-1:123456789012:certificate/abcdef-1234"
      ssl_policy       = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      target_group_key = "app"
    }
  }
}
```

### 3. Path-Based Routing with Listener Rules

```hcl
module "alb" {
  source = "../../modules/aws/application-load-balancer"

  name    = "microservices-alb"
  vpc_id  = "vpc-0123456789abcdef0"
  subnets = ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2"]

  create_security_group = true

  target_groups = {
    frontend = {
      port     = 80
      protocol = "HTTP"
    }
    api = {
      port     = 3000
      protocol = "HTTP"
    }
  }

  listeners = {
    http = {
      port             = 80
      protocol         = "HTTP"
      target_group_key = "frontend"
    }
  }

  listener_rules = {
    api_route = {
      listener_key     = "http"
      priority         = 10
      target_group_key = "api"
      conditions = {
        path_patterns = ["/api/*"]
      }
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
| name | The name of the Application Load Balancer. | `string` | `"app-load-balancer"` | no |
| name_prefix | Unique name prefix (max 6 characters). Conflicts with name. | `string` | `null` | no |
| internal | Whether the load balancer is internal or internet-facing. | `bool` | `false` | no |
| vpc_id | VPC ID for security groups and target groups. | `string` | `null` | no |
| subnets | List of at least two subnet IDs in different AZs. | `list(string)` | `[]` | no |
| subnet_mapping | Subnet mapping definitions for Elastic IP / private IP. | `list(object)` | `[]` | no |
| security_groups | List of existing Security Group IDs. | `list(string)` | `[]` | no |
| create_security_group | Whether to create a dedicated Security Group for the ALB. | `bool` | `false` | no |
| security_group_name | Name of dedicated security group. | `string` | `null` | no |
| security_group_ingress_rules | Ingress rules for dedicated security group. | `list(object)` | `[...]` | no |
| security_group_egress_rules | Egress rules for dedicated security group. | `list(object)` | `[...]` | no |
| idle_timeout | Idle timeout in seconds. | `number` | `60` | no |
| enable_deletion_protection | Protect ALB from deletion. | `bool` | `false` | no |
| enable_cross_zone_load_balancing | Cross-zone load balancing. | `bool` | `true` | no |
| enable_http2 | Enable HTTP/2. | `bool` | `true` | no |
| ip_address_type | IP address type (`ipv4` or `dualstack`). | `string` | `"ipv4"` | no |
| access_logs | Access logs configuration map. | `object` | `null` | no |
| connection_logs | Connection logs configuration map. | `object` | `null` | no |
| target_groups | Map of target group configurations. | `map(object)` | `{}` | no |
| target_group_attachments | Map of target attachments. | `map(object)` | `{}` | no |
| listeners | Map of listener configurations. | `map(object)` | `{}` | no |
| extra_certificates | Map of extra certificates for SNI. | `map(object)` | `{}` | no |
| listener_rules | Map of listener rules for routing. | `map(object)` | `{}` | no |
| waf_web_acl_arn | ARN of AWS WAF Web ACL to associate. | `string` | `null` | no |
| tags | Map of tags to apply to resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ARN of the Application Load Balancer. |
| arn | The ARN of the Application Load Balancer. |
| arn_suffix | The ARN suffix for CloudWatch Metrics. |
| dns_name | The DNS name of the ALB. |
| zone_id | Canonical hosted zone ID of the ALB (for Route 53 alias). |
| name | The name of the Application Load Balancer. |
| security_group_id | ID of the dedicated Security Group if created. |
| target_groups | Map of created target groups and their attributes. |
| target_group_arns | List of ARNs of all created target groups. |
| listeners | Map of created listeners and their attributes. |
| listener_rules | Map of created listener rules and their attributes. |
| tags_all | Map of tags assigned to the ALB. |
