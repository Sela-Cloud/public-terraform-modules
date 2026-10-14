# ECS Service Connect has no resource of its own: each service carries its Service Connect settings.
# What services share, and what outlives any one of them, is the Cloud Map namespace they join, so
# that is what this module owns. A cluster can name it as its default; services name it explicitly.
resource "aws_service_discovery_http_namespace" "this" {
  name        = var.name
  description = var.description
  tags        = var.tags
}
