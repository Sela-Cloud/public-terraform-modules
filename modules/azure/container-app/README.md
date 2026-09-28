# Azure Container App Terraform Child Module

Terraform module to provision an [Azure Container App](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app).

Azure Container Apps enables you to run microservices and containerized applications on a serverless platform built on Kubernetes. It features dynamic autoscaling (including scale to zero), traffic splitting, background processing, and managed ingress.

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
| [azurerm_container_app.container_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Specifies the name of the Container App. Changing this forces a new resource to be created. | `string` | n/a | yes |
| resource_group_name | Specifies the name of the Resource Group in which the Container App should exist. | `string` | n/a | yes |
| container_app_environment_id | The ID of the Container App Managed Environment. | `string` | n/a | yes |
| revision_mode | The revisions operational mode (`Single` or `Multiple`). | `string` | n/a | yes |
| template | A template block configuring container(s), scaling, and volume mounts. | `object` | n/a | yes |
| workload_profile_name | The name of the Workload Profile where this Container App should be placed. | `string` | `null` | no |
| ingress | Ingress block configuring external/internal access, target port, and traffic splitting. | `object` | `null` | no |
| identity | Managed Identity block to assign to the Container App. | `object` | `null` | no |
| secrets | A list of secrets available to the Container App. | `list(object)` | `[]` | no |
| registries | A list of container registry credential blocks. | `list(object)` | `[]` | no |
| dapr | A dapr block to configure Dapr settings for the Container App. | `object` | `null` | no |
| tags | A mapping of tags to assign to the Container App. | `map(string)` | `{}` | no |
| timeouts | Custom timeout durations for resource operations. | `object` | `{}` | no |

### Template Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| containers | List of container specifications (image, CPU, memory, env vars, probes). | `list(object)` | n/a | yes |
| init_containers | List of init containers executed before main containers start. | `list(object)` | `[]` | no |
| min_replicas | Minimum number of replicas (0 for scale to zero). | `number` | `0` | no |
| max_replicas | Maximum number of replicas. | `number` | `10` | no |
| revision_suffix | Suffix added to the revision name. | `string` | `null` | no |
| volumes | List of volume definitions. | `list(object)` | `[]` | no |
| http_scale_rules | HTTP request-based autoscaling rules. | `list(object)` | `[]` | no |
| tcp_scale_rules | TCP connection-based autoscaling rules. | `list(object)` | `[]` | no |
| custom_scale_rules | Custom (KEDA) autoscaling rules. | `list(object)` | `[]` | no |
| azure_queue_scale_rules | Azure Storage Queue backlog autoscaling rules. | `list(object)` | `[]` | no |

### Ingress Object

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| target_port | The port on the container that ingress traffic directs to. | `number` | n/a | yes |
| external_enabled | Whether access from outside the Container App Environment is allowed. | `bool` | `false` | no |
| transport | Transport method (`auto`, `http`, `http2`, `tcp`). | `string` | `"auto"` | no |
| allow_insecure_connections | Allow HTTP (insecure) traffic without redirecting to HTTPS. | `bool` | `false` | no |
| exposed_port | The exposed TCP port (required if transport is `tcp`). | `number` | `null` | no |
| traffic_weight | Traffic allocation across revisions. | `list(object)` | `[...]` | no |
| ip_security_restriction | IP filtering rules for incoming requests. | `list(object)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Container App. |
| name | The Name of the Container App. |
| fqdn | The FQDN of the Container App's ingress (if ingress is enabled). |
| latest_revision_fqdn | The FQDN of the latest revision of the Container App. |
| latest_revision_name | The name of the latest Container revision. |
| outbound_ip_addresses | The public IP addresses used for outbound traffic. |
| identity | The Managed Identity configuration block for the Container App. |
| container_app | The full Azure Container App resource object. |

## Usage Examples

### Web App with Public Ingress and Autoscaling

```hcl
module "container_app" {
  source = "../../modules/azure/container-app"

  name                         = "ca-web-api"
  resource_group_name          = "rg-prod-apps"
  container_app_environment_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-prod-apps/providers/Microsoft.App/managedEnvironments/cae-prod"
  revision_mode                = "Single"

  ingress = {
    external_enabled           = true
    target_port                = 8080
    transport                  = "auto"
    allow_insecure_connections = false
  }

  template = {
    min_replicas = 1
    max_replicas = 5

    containers = [
      {
        name   = "api"
        image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
        cpu    = 0.5
        memory = "1.0Gi"
        env = [
          {
            name  = "ASPNETCORE_ENVIRONMENT"
            value = "Production"
          }
        ]
      }
    ]

    http_scale_rules = [
      {
        name                = "http-scaling"
        concurrent_requests = "100"
      }
    ]
  }

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```
