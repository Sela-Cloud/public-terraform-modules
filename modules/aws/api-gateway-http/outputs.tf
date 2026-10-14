output "id" {
  description = "The ID of the HTTP API."
  value       = aws_apigatewayv2_api.this.id
}

output "arn" {
  description = "The ARN of the HTTP API."
  value       = aws_apigatewayv2_api.this.arn
}

output "api_endpoint" {
  description = "The default execute-api endpoint, e.g. https://abcdef123.execute-api.us-east-1.amazonaws.com."
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "execution_arn" {
  description = "The execution ARN, used to build source_arn values for resource-based policies (e.g. aws_lambda_permission)."
  value       = aws_apigatewayv2_api.this.execution_arn
}

output "stage_invoke_url" {
  description = "The invoke URL for this API's stage."
  value       = aws_apigatewayv2_stage.this.invoke_url
}

output "route_ids" {
  description = "Map of route keys (as given in var.routes) to their aws_apigatewayv2_route IDs."
  value       = { for k, v in aws_apigatewayv2_route.this : k => v.id }
}

output "authorizer_ids" {
  description = "Map of authorizer keys (as given in var.authorizers) to their aws_apigatewayv2_authorizer IDs."
  value       = local.authorizer_ids
}

output "vpc_link_id" {
  description = "The ID of the VPC Link, if create_vpc_link is true."
  value       = try(aws_apigatewayv2_vpc_link.this[0].id, null)
}

output "domain_target_domain_name" {
  description = "The domain name target to point a DNS alias record at (e.g. via the route53-record module), if domain_name is set."
  value       = try(aws_apigatewayv2_domain_name.this[0].domain_name_configuration[0].target_domain_name, null)
}

output "domain_hosted_zone_id" {
  description = "The hosted zone ID to use for a Route 53 alias record, if domain_name is set."
  value       = try(aws_apigatewayv2_domain_name.this[0].domain_name_configuration[0].hosted_zone_id, null)
}
