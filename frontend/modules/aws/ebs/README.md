# AWS EBS Volume Frontend Module

This frontend module wraps the core AWS EBS volume module for the Sela Craft platform, supporting multi-instance map variables and `ui-metadata.json`.

## Usage

```hcl
module "ebs_volumes" {
  source = "./frontend/modules/aws/ebs"

  region = "us-east-1"

  ebs = {
    "app-disk-1" = {
      name              = "app-disk-1"
      availability_zone = "us-east-1a"
      size              = 50
      type              = "gp3"
      encrypted         = true
    }
  }
}
```
