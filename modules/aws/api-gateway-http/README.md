# AWS API Gateway HTTP API Terraform Module

This generic Terraform module provisions an Amazon API Gateway **HTTP API** -- the modern,
lighter-weight API Gateway generation (`aws_apigatewayv2_*`), recommended by AWS for new work unless
you specifically need REST-API-only features (API keys/usage plans, request/response transformation,
AWS WAF integration, private VPC-endpoint APIs, mock integrations). This module covers routes with
Lambda-proxy or HTTP-proxy integrations (including private ALB/NLB targets via a VPC Link), JWT or
Lambda authorizers, a deployment stage, and an optional custom domain.

**REST API and WebSocket API are explicitly out of scope** -- they are separate, much larger resource
families (`aws_api_gateway_*` for REST), tracked as a possible future addition, not built here.

## Usage

### Lambda-backed routes with a JWT authorizer

```hcl
module "api_gateway" {
  source = "../../modules/aws/api-gateway-http"

  name = "orders-api"

  authorizers = [
    {
      key              = "jwt1"
      name             = "cognito-jwt"
      authorizer_type  = "JWT"
      identity_sources = ["$request.header.Authorization"]
      jwt_issuer       = "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_abc123"
      jwt_audience     = ["abc123client"]
    }
  ]

  routes = [
    {
      key                 = "get_orders"
      route_key           = "GET /orders"
      integration_type    = "AWS_PROXY"
      lambda_function_arn = module.get_orders_lambda.function_arn
    },
    {
      key                 = "post_orders"
      route_key           = "POST /orders"
      integration_type    = "AWS_PROXY"
      lambda_function_arn = module.create_order_lambda.function_arn
      authorization_type  = "JWT"
      authorizer_key      = "jwt1"
    }
  ]
}
```

### Private backend via a VPC Link, controlled deployment, custom domain

```hcl
module "api_gateway" {
  source = "../../modules/aws/api-gateway-http"

  name        = "internal-api"
  auto_deploy = false

  create_vpc_link             = true
  vpc_link_security_group_ids = [aws_security_group.apigw_vpc_link.id]
  vpc_link_subnet_ids         = module.vpc.private_subnet_ids

  routes = [
    {
      key              = "proxy_all"
      route_key        = "$default"
      integration_type = "HTTP_PROXY"
      connection_type  = "VPC_LINK"
      integration_uri  = aws_lb_listener.internal.arn
    }
  ]

  domain_name     = "api.internal.example.com"
  certificate_arn = aws_acm_certificate.internal_api.arn
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0.0 |

## Inputs

See `variables.tf` for the full list. Notable shapes:

- `routes` -- repeatable, each entry gets its own integration. `integration_type` is `AWS_PROXY`
  (Lambda, requires `lambda_function_arn`; an `aws_lambda_permission` is created automatically --
  confirmed from the provider's own docs that API Gateway cannot invoke a Lambda without one) or
  `HTTP_PROXY` (an HTTP backend, or a private ALB/NLB listener/Cloud Map service via a VPC Link,
  requires `integration_uri`).
- `authorizers` -- repeatable, referenced by a route's `authorizer_key`. `JWT` requires `jwt_issuer`;
  `REQUEST` (Lambda) requires `authorizer_lambda_arn`.
- `auto_deploy` (default `true`) -- the normal path, where route/integration changes deploy
  automatically. When `false`, the module creates an explicit `aws_apigatewayv2_deployment` with a
  `triggers` hash over `var.routes` and `create_before_destroy`, exactly per the provider's own
  documented recipe for this -- a real, confirmed Terraform/API-Gateway gotcha, not a guess.

## Outputs

| Name | Description |
|------|-------------|
| id / arn | API identifiers. |
| api_endpoint | The default execute-api endpoint. |
| execution_arn | Used to build `source_arn` values for resource-based policies. |
| stage_invoke_url | The stage's invoke URL. |
| route_ids / authorizer_ids | Maps of your own keys to the created resources' IDs. |
| vpc_link_id | Present when `create_vpc_link` is true. |
| domain_target_domain_name / domain_hosted_zone_id | Present when `domain_name` is set -- point a Route 53 alias record at these manually (e.g. via the `route53-record` module), not auto-wired here. |

## Notes, verified against the real AWS provider and its documentation

- **`protocol_type` is fixed to `HTTP`** -- `aws_apigatewayv2_api` also supports `WEBSOCKET`, a
  different route-key model and out of scope for this module.
- **Quick-create (`body`/`route_key`/`target` directly on the API resource) is deliberately not
  used** -- the provider's own docs warn that mixing it with separately-managed route/integration
  resources "may cause manual resource updates to be overwritten." This module always manages
  routes/integrations explicitly.
- **HTTP API custom domains are REGIONAL-only** -- no edge-optimized option exists (that's a REST-API-
  only concept), so `certificate_arn` just needs to be in this API's own region, not necessarily
  `us-east-1`.
- **`aws_lambda_permission` is not automatic** -- confirmed from the provider's own `aws_lambda_permission`
  doc example; without it, Lambda-proxy routes 500 with an authorization error. This module creates
  one per `AWS_PROXY` route.
- Deliberately **out of scope**, with no misleading half-support: REST API, WebSocket API, API
  keys/usage plans, request/response models, and a CloudWatch Logs log-group lookup for
  `access_log_destination_arn` (no such lookup exists in this catalog yet -- enter the ARN directly,
  same honest-gap treatment as other unwired fields).
