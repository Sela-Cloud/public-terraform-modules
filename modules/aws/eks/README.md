# AWS Elastic Kubernetes Service (EKS) Terraform Module

This generic Terraform module provisions and manages an Amazon Elastic Kubernetes Service (EKS) cluster along with IAM roles, dedicated security groups, OIDC provider for IRSA, managed node groups, EKS managed addons, and EKS access entries.

## Features

- **EKS Cluster (`aws_eks_cluster`)**:
  - Control plane provisioning with configurable Kubernetes versions (e.g. `1.31`, `1.30`).
  - Private and public API server endpoints with CIDR whitelisting.
  - Granular control plane logging (`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`).
  - KMS encryption for Kubernetes secrets.
  - Dedicated IAM role with `AmazonEKSClusterPolicy` and `AmazonEKSVPCResourceController`.
- **OIDC Provider (`aws_iam_openid_connect_provider`)**:
  - Automated IAM OIDC Identity Provider setup to support IAM Roles for Service Accounts (IRSA).
- **Managed Node Groups (`aws_eks_node_group`)**:
  - Auto-scaling node groups with configurable `min_size`, `max_size`, and `desired_size`.
  - On-Demand and Spot instances (`capacity_type`).
  - Multi-architecture support: Amazon Linux 2023 (`AL2023_x86_64_STANDARD`), Bottlerocket, etc.
  - Automated worker node IAM role creation (`AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, `AmazonEC2ContainerRegistryReadOnly`).
  - Kubernetes labels and taints.
- **EKS Managed Addons (`aws_eks_addon`)**:
  - Seamless installation and version management for `vpc-cni`, `coredns`, `kube-proxy`, and `eks-pod-identity-agent`.
- **EKS Access Entries (`aws_eks_access_entry`)**:
  - Modern Kubernetes authorization via AWS IAM without depending on legacy `aws-auth` ConfigMaps.
  - Cluster Admin and Namespace-scoped access policy associations.

---

## Architecture

```
                         AWS VPC (vpc_id)
                                │
        ┌───────────────────────┴───────────────────────┐
        ▼                                               ▼
┌───────────────────────────────┐               ┌───────────────────────────────┐
│     EKS Control Plane         │               │     Managed Node Groups       │
│    (aws_eks_cluster)          │◄─────────────►│    (aws_eks_node_group)       │
│  - Kubernetes API Server      │  Cluster SG   │  - Auto-Scaling Worker Nodes  │
│  - IAM Cluster Role           │               │  - Worker Node IAM Role       │
│  - Control Plane Logging      │               │  - On-Demand / Spot Compute   │
└───────────────┬───────────────┘               └───────────────────────────────┘
                │
                ▼
┌───────────────────────────────┐
│     OIDC Identity Provider    │ ────► IAM Roles for Service Accounts (IRSA)
│ (aws_iam_openid_connect_...)  │
└───────────────────────────────┘
```

---

## Usage Examples

### 1. Standard EKS Cluster with Managed Node Group

```hcl
module "eks" {
  source = "../../modules/aws/eks"

  name               = "production-eks"
  kubernetes_version = "1.31"
  vpc_id             = "vpc-0123456789abcdef0"
  subnet_ids         = ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2"]

  node_groups = {
    general = {
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      scaling_config = {
        desired_size = 2
        min_size     = 1
        max_size     = 4
      }
    }
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```

### 2. EKS Cluster with Managed Addons and Access Entries

```hcl
module "eks" {
  source = "../../modules/aws/eks"

  name               = "cloud-eks"
  kubernetes_version = "1.31"
  vpc_id             = "vpc-0123456789abcdef0"
  subnet_ids         = ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2"]

  node_groups = {
    compute = {
      instance_types = ["t3.large"]
      scaling_config = {
        desired_size = 3
        min_size     = 2
        max_size     = 6
      }
    }
  }

  cluster_addons = {
    vpc_cni = {
      addon_name = "vpc-cni"
    }
    coredns = {
      addon_name = "coredns"
    }
    kube_proxy = {
      addon_name = "kube-proxy"
    }
  }

  access_entries = {
    devops_admin = {
      principal_arn = "arn:aws:iam::123456789012:role/DevOpsAdminRole"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
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
| tls | >= 4.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the EKS cluster. | `string` | `"eks-cluster"` | no |
| kubernetes_version | Kubernetes version for the cluster. | `string` | `"1.31"` | no |
| vpc_id | VPC ID where cluster resources reside. | `string` | `null` | no |
| subnet_ids | Subnet IDs for control plane and nodes. If empty, auto-discovered. | `list(string)` | `[]` | no |
| endpoint_private_access | Enable private API endpoint. | `bool` | `true` | no |
| endpoint_public_access | Enable public API endpoint. | `bool` | `true` | no |
| public_access_cidrs | CIDRs with access to public API. | `list(string)` | `["0.0.0.0/0"]` | no |
| kubernetes_network_config | Network config for service IPv4 CIDR and IP family (ipv4/ipv6). | `object` | `null` | no |
| upgrade_policy_support_type | Cluster upgrade support type (`STANDARD` or `EXTENDED`). | `string` | `null` | no |
| enable_zonal_shift | Enable zonal shift resiliency. | `bool` | `false` | no |
| bootstrap_self_managed_addons | Install default self-managed addons on creation. | `bool` | `true` | no |
| create_iam_role | Create IAM role for cluster. | `bool` | `true` | no |
| create_oidc_provider | Create IAM OIDC provider for IRSA. | `bool` | `true` | no |
| node_groups | Map of managed node groups (supports launch templates, SSH). | `map(object)` | `{}` | no |
| create_node_iam_role | Create worker node IAM role. | `bool` | `true` | no |
| cluster_addons | Map of EKS managed addons. | `map(object)` | `{}` | no |
| access_entries | Map of EKS Access Entries. | `map(object)` | `{}` | no |
| pod_identity_associations | Map of EKS Pod Identity associations. | `map(object)` | `{}` | no |
| tags | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | Name / ID of the EKS cluster. |
| cluster_arn | Amazon Resource Name (ARN) of the cluster. |
| cluster_name | Name of the EKS cluster. |
| cluster_endpoint | Endpoint URL for the Kubernetes API server. |
| cluster_version | Kubernetes version of the cluster. |
| cluster_status | Status of the cluster (e.g. ACTIVE). |
| cluster_certificate_authority_data | Base64 encoded CA certificate data. |
| cluster_security_group_id | Security group created by AWS EKS for control plane to node traffic. |
| cluster_iam_role_arn | IAM role ARN of the cluster control plane. |
| cluster_service_cidr | Service IPv4 CIDR block used by Kubernetes. |
| cluster_ip_family | IP family used by the cluster (ipv4 or ipv6). |
| oidc_provider_arn | OIDC provider ARN for IRSA. |
| node_groups | Map of created node groups with attributes. |
| node_iam_role_arn | IAM role ARN of worker nodes. |
| cluster_addons | Map of created addons. |
| pod_identity_associations | Map of created EKS Pod Identity associations. |

