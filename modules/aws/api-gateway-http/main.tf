data "aws_region" "current" {}

################################################################################
# HTTP API
################################################################################

resource "aws_apigatewayv2_api" "this" {
  name                         = var.name
  protocol_type                = "HTTP"
  description                  = var.description
  disable_execute_api_endpoint = var.disable_execute_api_endpoint

  dynamic "cors_configuration" {
    for_each = var.cors_configuration != null ? [var.cors_configuration] : []
    content {
      allow_credentials = cors_configuration.value.allow_credentials
      allow_headers     = cors_configuration.value.allow_headers
      allow_methods     = cors_configuration.value.allow_methods
      allow_origins     = cors_configuration.value.allow_origins
      expose_headers    = cors_configuration.value.expose_headers
      max_age           = cors_configuration.value.max_age
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )

  lifecycle {
    precondition {
      condition     = length(distinct([for r in var.routes : r.key])) == length(var.routes)
      error_message = "Each routes entry needs a unique key."
    }
    precondition {
      condition     = length(distinct([for a in var.authorizers : a.key])) == length(var.authorizers)
      error_message = "Each authorizers entry needs a unique key."
    }
    precondition {
      condition = alltrue([
        for r in var.routes : r.integration_type != "AWS_PROXY" || r.lambda_function_arn != null
      ])
      error_message = "lambda_function_arn is required when a route's integration_type is 'AWS_PROXY'."
    }
    precondition {
      condition = alltrue([
        for r in var.routes : r.integration_type != "HTTP_PROXY" || r.integration_uri != null
      ])
      error_message = "integration_uri is required when a route's integration_type is 'HTTP_PROXY'."
    }
    precondition {
      condition = alltrue([
        for r in var.routes : contains(["AWS_PROXY", "HTTP_PROXY"], r.integration_type)
      ])
      error_message = "Each route's integration_type must be 'AWS_PROXY' or 'HTTP_PROXY'."
    }
    precondition {
      condition = alltrue([
        for r in var.routes : r.connection_type != "VPC_LINK" || r.connection_id != null || var.create_vpc_link
      ])
      error_message = "A route with connection_type 'VPC_LINK' needs its own connection_id, unless create_vpc_link is true (the module's own VPC Link is then used by default)."
    }
    precondition {
      condition = alltrue([
        for r in var.routes : r.authorizer_key == null || contains([for a in var.authorizers : a.key], r.authorizer_key)
      ])
      error_message = "Each route's authorizer_key must match an existing authorizers entry's key."
    }
    precondition {
      condition = alltrue([
        for a in var.authorizers : a.authorizer_type != "REQUEST" || a.authorizer_lambda_arn != null
      ])
      error_message = "authorizer_lambda_arn is required when an authorizer's authorizer_type is 'REQUEST'."
    }
    precondition {
      condition = alltrue([
        for a in var.authorizers : a.authorizer_type != "JWT" || a.jwt_issuer != null
      ])
      error_message = "jwt_issuer is required when an authorizer's authorizer_type is 'JWT'."
    }
    precondition {
      condition     = var.domain_name == null || var.certificate_arn != null
      error_message = "certificate_arn is required when domain_name is set."
    }
    precondition {
      condition     = !var.create_vpc_link || (length(var.vpc_link_security_group_ids) > 0 && length(var.vpc_link_subnet_ids) > 0)
      error_message = "vpc_link_security_group_ids and vpc_link_subnet_ids are required when create_vpc_link is true."
    }
  }
}

################################################################################
# VPC Link
################################################################################

resource "aws_apigatewayv2_vpc_link" "this" {
  count = var.create_vpc_link ? 1 : 0

  name               = "${var.name}-vpc-link"
  security_group_ids = var.vpc_link_security_group_ids
  subnet_ids         = var.vpc_link_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-vpc-link"
    }
  )
}

################################################################################
# Authorizers
################################################################################

resource "aws_apigatewayv2_authorizer" "this" {
  for_each = { for a in var.authorizers : a.key => a }

  api_id           = aws_apigatewayv2_api.this.id
  name             = each.value.name
  authorizer_type  = each.value.authorizer_type
  identity_sources = each.value.identity_sources

  authorizer_uri = each.value.authorizer_type == "REQUEST" ? (
    "arn:aws:apigateway:${data.aws_region.current.region}:lambda:path/2015-03-31/functions/${each.value.authorizer_lambda_arn}/invocations"
  ) : null
  authorizer_payload_format_version = each.value.authorizer_type == "REQUEST" ? each.value.authorizer_payload_format_version : null
  enable_simple_responses           = each.value.authorizer_type == "REQUEST" ? each.value.enable_simple_responses : null
  authorizer_result_ttl_in_seconds  = each.value.authorizer_result_ttl_in_seconds

  dynamic "jwt_configuration" {
    for_each = each.value.authorizer_type == "JWT" ? [each.value] : []
    content {
      issuer   = jwt_configuration.value.jwt_issuer
      audience = jwt_configuration.value.jwt_audience
    }
  }
}

locals {
  authorizer_ids = { for k, v in aws_apigatewayv2_authorizer.this : k => v.id }
}

################################################################################
# Integrations & Routes
################################################################################

resource "aws_apigatewayv2_integration" "this" {
  for_each = { for r in var.routes : r.key => r }

  api_id             = aws_apigatewayv2_api.this.id
  integration_type   = each.value.integration_type
  integration_method = each.value.integration_type == "HTTP_PROXY" ? "ANY" : null
  integration_uri    = each.value.integration_type == "AWS_PROXY" ? each.value.lambda_function_arn : each.value.integration_uri

  connection_type = each.value.integration_type == "HTTP_PROXY" ? each.value.connection_type : null
  connection_id = (
    each.value.integration_type == "HTTP_PROXY" && each.value.connection_type == "VPC_LINK" ?
    coalesce(each.value.connection_id, try(aws_apigatewayv2_vpc_link.this[0].id, null)) :
    null
  )

  payload_format_version = each.value.integration_type == "AWS_PROXY" ? each.value.payload_format_version : null
  timeout_milliseconds   = each.value.timeout_milliseconds
}

resource "aws_apigatewayv2_route" "this" {
  for_each = { for r in var.routes : r.key => r }

  api_id             = aws_apigatewayv2_api.this.id
  route_key          = each.value.route_key
  target             = "integrations/${aws_apigatewayv2_integration.this[each.key].id}"
  authorization_type = each.value.authorization_type
  authorizer_id      = each.value.authorizer_key != null ? local.authorizer_ids[each.value.authorizer_key] : null
  api_key_required   = each.value.api_key_required
}

resource "aws_lambda_permission" "this" {
  for_each = { for r in var.routes : r.key => r if r.integration_type == "AWS_PROXY" }

  statement_id  = "AllowAPIGatewayInvoke-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}

################################################################################
# Stage
################################################################################

resource "aws_apigatewayv2_deployment" "this" {
  count = var.auto_deploy ? 0 : 1

  api_id      = aws_apigatewayv2_api.this.id
  description = "Managed by Terraform"

  triggers = {
    redeployment = sha1(jsonencode(var.routes))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_stage" "this" {
  api_id        = aws_apigatewayv2_api.this.id
  name          = var.stage_name
  auto_deploy   = var.auto_deploy
  deployment_id = var.auto_deploy ? null : aws_apigatewayv2_deployment.this[0].id

  dynamic "access_log_settings" {
    for_each = var.access_log_destination_arn != null ? [1] : []
    content {
      destination_arn = var.access_log_destination_arn
      format = coalesce(var.access_log_format, jsonencode({
        requestId      = "$context.requestId"
        ip             = "$context.identity.sourceIp"
        requestTime    = "$context.requestTime"
        httpMethod     = "$context.httpMethod"
        routeKey       = "$context.routeKey"
        status         = "$context.status"
        protocol       = "$context.protocol"
        responseLength = "$context.responseLength"
      }))
    }
  }

  dynamic "default_route_settings" {
    for_each = [var.default_route_settings]
    content {
      throttling_burst_limit   = default_route_settings.value.throttling_burst_limit
      throttling_rate_limit    = default_route_settings.value.throttling_rate_limit
      detailed_metrics_enabled = default_route_settings.value.detailed_metrics_enabled
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-${var.stage_name}"
    }
  )
}

################################################################################
# Custom Domain
################################################################################

resource "aws_apigatewayv2_domain_name" "this" {
  count       = var.domain_name != null ? 1 : 0
  domain_name = var.domain_name

  domain_name_configuration {
    certificate_arn = var.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = var.security_policy
  }

  tags = merge(
    var.tags,
    {
      Name = var.domain_name
    }
  )
}

resource "aws_apigatewayv2_api_mapping" "this" {
  count = var.domain_name != null ? 1 : 0

  api_id          = aws_apigatewayv2_api.this.id
  domain_name     = aws_apigatewayv2_domain_name.this[0].id
  stage           = aws_apigatewayv2_stage.this.name
  api_mapping_key = var.api_mapping_key
}
