output "functions" {
  description = "A map of all created Azure Function App Function module instances."
  value       = module.function_app_function
}

output "function_ids" {
  description = "A map of Function names to their respective resource IDs."
  value       = { for k, v in module.function_app_function : k => v.id }
}

output "function_urls" {
  description = "A map of Function names to their respective invocation URLs."
  value       = { for k, v in module.function_app_function : k => v.url }
}
