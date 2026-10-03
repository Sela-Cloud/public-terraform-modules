# AWS EKS Frontend Module

This frontend module wraps the core AWS EKS module for the Sela Craft platform, supporting dynamic UI generation, resource maps, and `ui-metadata.json`.

## Usage

```hcl
module "eks" {
  source = "./frontend/modules/aws/eks"

  region = "us-east-1"

  eks = {
    "prod-cluster" = {
      name               = "prod-cluster"
      kubernetes_version = "1.31"
      vpc_id             = "vpc-0123456789abcdef0"
      subnet_ids         = ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2"]

      node_groups = {
        "general" = {
          node_group_name = "prod-general-nodes"
          instance_types  = ["t3.medium"]
          scaling_config = {
            desired_size = 2
            min_size     = 1
            max_size     = 4
          }
        }
      }

      cluster_addons = {
        "vpc-cni" = {
          addon_name = "vpc-cni"
        }
        "coredns" = {
          addon_name = "coredns"
        }
        "kube-proxy" = {
          addon_name = "kube-proxy"
        }
      }

      tags = {
        Environment = "production"
        ManagedBy   = "Terraform"
      }
    }
  }
}
```
