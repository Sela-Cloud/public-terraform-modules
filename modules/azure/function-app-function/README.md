# Azure Function App Function Terraform Child Module

Terraform module to provision an [Azure Function App Function](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app_function).

An Azure Function App Function represents an individual function within an existing Azure Function App, managing triggers, input/output bindings, test data, and source code files.

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
| [azurerm_function_app_function.function](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app_function) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the function. Changing this forces a new resource to be created. | `string` | n/a | yes |
| function_app_id | The ID of the Function App in which this function should reside. | `string` | n/a | yes |
| config_json | The config for this Function in JSON format (bindings, triggers, and returns). | `string` | n/a | yes |
| enabled | Should this function be enabled. | `bool` | `true` | no |
| language | The language the Function is written in (`CSharp`, `Custom`, `Java`, `Javascript`, `Python`, `PowerShell`, `TypeScript`). | `string` | `null` | no |
| files | A list of file blocks representing source code files for the function. | `list(object)` | `[]` | no |
| test_data | The test data for the function in JSON format. | `string` | `null` | no |
| timeouts | Custom timeout durations for resource operations. | `object` | `{}` | no |

### File Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| name | The filename of the source file (e.g. `run.csx`, `index.js`, `__init__.py`). | `string` | n/a | yes |
| content | The content of the source file. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Function App Function. |
| name | The Name of the Function. |
| url | The invocation URL of the function, if HTTP triggered. |
| function | The full Azure Function App Function resource object. |

## Usage Examples

### HTTP-Triggered Function

```hcl
module "http_function" {
  source = "../../modules/azure/function-app-function"

  name            = "HelloWorldHttp"
  function_app_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-my-apps/providers/Microsoft.Web/sites/fa-my-workload"
  language        = "Javascript"
  enabled         = true

  config_json = jsonencode({
    bindings = [
      {
        authLevel = "function"
        direction = "in"
        methods   = ["get", "post"]
        name      = "req"
        type      = "httpTrigger"
      },
      {
        direction = "out"
        name      = "res"
        type      = "http"
      }
    ]
  })

  files = [
    {
      name    = "index.js"
      content = <<-EOT
        module.exports = async function (context, req) {
          context.res = {
            status: 200,
            body: "Hello from Azure Functions via Terraform!"
          };
        };
      EOT
    }
  ]
}
```
