# Azure Policy Definition Terraform Child Module

Terraform module to provision an [Azure Policy Definition](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition).

This module manages Azure Policy Definitions at the subscription or management group scope, enabling compliance and governance as code across Azure resources.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | >= 3.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.0.0, < 5.0.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_policy_definition.policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Policy Definition. Changing this forces a new resource to be created. | `string` | n/a | yes |
| display_name | The display name of the Policy Definition. | `string` | n/a | yes |
| policy_type | The policy type. Possible values are `BuiltIn`, `Custom`, `NotSpecified`, and `Static`. | `string` | `"Custom"` | no |
| mode | The policy resource manager mode that determines which resource types will be evaluated. | `string` | `"All"` | no |
| description | The description of the Policy Definition. | `string` | `null` | no |
| management_group_id | The ID of the Management Group where this policy definition should be defined. | `string` | `null` | no |
| policy_rule | The policy rule for the policy definition in JSON format. | `string` | `null` | no |
| metadata | The metadata for the policy definition in JSON format. | `string` | `null` | no |
| parameters | Parameters for the policy definition in JSON format. | `string` | `null` | no |
| timeouts | Custom timeout durations for resource operations. | `object` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Policy Definition. |
| name | The Name of the Policy Definition. |
| role_definition_ids | The list of Role Definition IDs extracted from the policy rule. |
| policy_definition | The full Azure Policy Definition resource object. |

## Usage Examples

### Custom Audit Policy at Subscription Scope

```hcl
module "audit_vm_sizes" {
  source = "../../modules/azure/policy-definition"

  name         = "audit-vm-sizes"
  display_name = "Audit Virtual Machine SKUs"
  description  = "Audits Virtual Machines to ensure only approved SKUs are deployed."
  policy_type  = "Custom"
  mode         = "Indexed"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Compute/virtualMachines"
        },
        {
          not = {
            field = "Microsoft.Compute/virtualMachines/sku.name"
            in    = "[parameters('allowedSizes')]"
          }
        }
      ]
    }
    then = {
      effect = "audit"
    }
  })

  parameters = jsonencode({
    allowedSizes = {
      type = "Array"
      metadata = {
        displayName = "Allowed VM Sizes"
        description = "List of approved VM sizes."
      }
      defaultValue = ["Standard_B2s", "Standard_D2s_v5"]
    }
  })

  metadata = jsonencode({
    category = "Compute"
    version  = "1.0.0"
  })
}
```

### Policy Definition at Management Group Scope

```hcl
module "require_resource_tags" {
  source = "../../modules/azure/policy-definition"

  name                = "require-cost-center-tag"
  display_name        = "Require CostCenter Tag on Resources"
  description         = "Enforces a required CostCenter tag on all resources."
  management_group_id = "/providers/Microsoft.Management/managementGroups/mg-enterprise"
  mode                = "Indexed"

  policy_rule = jsonencode({
    if = {
      field  = "tags['CostCenter']"
      exists = "false"
    }
    then = {
      effect = "deny"
    }
  })

  metadata = jsonencode({
    category = "Tags"
  })
}
```
