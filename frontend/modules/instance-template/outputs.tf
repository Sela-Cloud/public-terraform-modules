output "instance_template_self_links" {
  description = "Unique self-link of each instance template, keyed by resource name. Use this as the MIG's instance template."
  value       = { for key, tpl in module.instance_template : key => tpl.self_link_unique }
}

output "instance_template_names" {
  description = "Generated name of each instance template, keyed by resource name."
  value       = { for key, tpl in module.instance_template : key => tpl.name }
}

output "instance_template_tags" {
  description = "Network tags associated with the instances each template creates, keyed by resource name."
  value       = { for key, tpl in module.instance_template : key => tpl.tags }
}
