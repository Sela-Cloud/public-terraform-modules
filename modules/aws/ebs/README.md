# AWS EBS Volume Terraform Module

This module provisions an AWS EBS (Elastic Block Store) Volume with configurable storage types, IOPS, throughput, encryption, and snapshots.

## Usage

```hcl
module "ebs_volume" {
  source            = "path/to/modules/aws/ebs"
  name              = "my-ebs-volume"
  availability_zone = "us-east-1a"
  size              = 50
  type              = "gp3"
  encrypted         = true

  tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| availability\_zone | AZ where the EBS volume will exist | `string` | n/a | yes |
| name | Name identifier applied as the 'Name' tag | `string` | `"ebs-volume"` | no |
| size | Size of drive in GiBs | `number` | `20` | no |
| type | EBS volume type (gp2, gp3, io1, io2, st1, sc1, standard) | `string` | `"gp3"` | no |
| iops | Provisioned IOPS | `number` | `null` | no |
| throughput | Throughput in MiB/s for gp3 volumes | `number` | `null` | no |
| encrypted | Enable encryption | `bool` | `true` | no |
| kms\_key\_id | KMS Key ARN for encryption | `string` | `null` | no |
| snapshot\_id | Snapshot ID to restore from | `string` | `null` | no |
| multi\_attach\_enabled | Enable Multi-Attach (io1/io2) | `bool` | `false` | no |
| final\_snapshot | Create snapshot before deletion | `bool` | `false` | no |
| tags | Map of resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the EBS volume |
| arn | The ARN of the EBS volume |
| size | Volume size in GiBs |
| type | EBS volume type |
| availability\_zone | Volume Availability Zone |
