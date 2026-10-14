# AWS DynamoDB Terraform Module

This generic Terraform module provisions an Amazon DynamoDB table, with secondary indexes (GSI/LSI),
TTL, point-in-time recovery, server-side encryption, Global Tables v2 replicas, Contributor Insights,
and Application Auto Scaling targets for provisioned capacity.

## Usage

### On-demand capacity, with a composite key and a GSI

```hcl
module "dynamodb" {
  source = "../../modules/aws/dynamodb"

  name         = "orders"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"
  range_key    = "sk"

  attribute = [
    { name = "pk", type = "S" },
    { name = "sk", type = "S" },
    { name = "gsi1pk", type = "S" },
  ]

  global_secondary_index = [
    {
      key             = "by_gsi1"
      name            = "gsi1"
      hash_key        = "gsi1pk"
      projection_type = "ALL"
    }
  ]

  point_in_time_recovery = {
    enabled = true
  }
}
```

### Provisioned capacity, with auto scaling and a Global Tables replica

```hcl
module "dynamodb" {
  source = "../../modules/aws/dynamodb"

  name           = "sessions"
  billing_mode   = "PROVISIONED"
  hash_key       = "id"
  read_capacity  = 5
  write_capacity = 5

  attribute = [{ name = "id", type = "S" }]

  replica = [
    { key = "eu", region_name = "eu-west-1" }
  ]

  autoscaling = [
    { key = "table_r", dimension = "table_read", min_capacity = 5, max_capacity = 100 },
    { key = "table_w", dimension = "table_write", min_capacity = 5, max_capacity = 100 },
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

See `variables.tf` for the full list. Notable shapes:

- `attribute` -- only attributes actually used as a key (table or index) belong here. Adding unused
  attributes causes an infinite plan loop (confirmed from the provider's own docs).
- `global_secondary_index` / `local_secondary_index` -- repeatable, each needs a unique `key`
  (Terraform-only, not sent to AWS).
- `replica` -- Global Tables v2 regions, a repeatable block directly on the table resource (not a
  separate resource type).
- `autoscaling` -- builds `aws_appautoscaling_target` + `aws_appautoscaling_policy` pairs; DynamoDB
  has no dedicated autoscaling resource of its own.

## Outputs

| Name | Description |
|------|-------------|
| id / arn / name | Table identifiers. |
| stream_arn / stream_label | Present when `stream_enabled` is true. |
| replica | The table's replica regions and their computed ARNs/stream details. |
| contributor_insights_id | Present when `contributor_insights_enabled` is true. |
| autoscaling_target_resource_ids | Map of autoscaling entry keys to their Application Auto Scaling resource IDs. |

## Notes, verified against the real AWS provider and its documentation

- **`billing_mode`**: `PROVISIONED` (default) requires `read_capacity`/`write_capacity` (and the same
  per-GSI); `PAY_PER_REQUEST` requires they be left null. Both enforced by preconditions.
- **`local_secondary_index` requires the table to have its own `range_key`** -- LSIs need a composite
  primary key, and can only be set at table creation (not added later).
- **`ttl.attribute_name` is required when `ttl.enabled` is true**, and left null otherwise.
- **`server_side_encryption`**: if `enabled` is false, AWS uses its own owned key (`DEFAULT` in the
  console). If `enabled` is true and `kms_key_arn` is null, AWS uses the default AWS-managed key
  (`KMS` in the console). Set `kms_key_arn` for a customer-managed key.
- **Auto scaling only applies when `billing_mode` is `PROVISIONED`**, and a `gsi_read`/`gsi_write`
  entry's `index_name` must match an existing `global_secondary_index` name -- both enforced by
  preconditions.
- Deliberately **out of scope**, with no misleading half-support: `import_table` (one-time bulk load,
  doesn't fit a create-infra UI flow), `aws_dynamodb_resource_policy` (niche resource-based policy),
  `aws_dynamodb_tag` (only a workaround for replica tag-drift already handled by `replica.propagate_tags`),
  and `global_table_witness` (3-region MRSC witness, narrow use case).
- `kms_key_arn` fields (table and replica) are plain text -- wire them to your catalog's KMS key
  lookup in the frontend wrapper, same as any other KMS-backed field.
