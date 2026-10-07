output "pipeline_id" {
  description = "The ID of the Image Builder pipeline."
  value       = aws_imagebuilder_image_pipeline.this.id
}

output "pipeline_arn" {
  description = "The ARN of the Image Builder pipeline."
  value       = aws_imagebuilder_image_pipeline.this.arn
}

output "pipeline_name" {
  description = "The name of the Image Builder pipeline."
  value       = aws_imagebuilder_image_pipeline.this.name
}

output "recipe_arn" {
  description = "The ARN of the Image Recipe."
  value       = aws_imagebuilder_image_recipe.this.arn
}

output "recipe_id" {
  description = "The ID of the Image Recipe."
  value       = aws_imagebuilder_image_recipe.this.id
}

output "infrastructure_configuration_arn" {
  description = "The ARN of the Infrastructure Configuration."
  value       = aws_imagebuilder_infrastructure_configuration.this.arn
}

output "infrastructure_configuration_id" {
  description = "The ID of the Infrastructure Configuration."
  value       = aws_imagebuilder_infrastructure_configuration.this.id
}
