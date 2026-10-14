# AWS EKS Frontend Module

This frontend module wraps the core AWS EKS module for the Sela Craft platform, supporting dynamic UI generation, resource maps, and `ui-metadata.json`.

Each form entry creates exactly one EKS cluster, its optional dedicated IAM roles and security group, managed node groups, access entries, cluster addons, and pod identity associations.

## Usage

```hcl
module "eks" {
  source = "./frontend/modules/aws/eks"

  region = "us-east-1"

  eks = {
    "my-cluster" = {
      vpc_id     = "vpc-0123456789abcdef0"
      subnet_ids = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]

      node_groups = [
        {
          key            = "default"
          instance_types = ["t3.medium"]
        }
      ]

      cluster_addons = [
        { key = "vpc-cni", addon_name = "vpc-cni" },
        { key = "coredns", addon_name = "coredns" },
        { key = "kube-proxy", addon_name = "kube-proxy" }
      ]

      tags = {
        Environment = "production"
      }
    }
  }
}
```
