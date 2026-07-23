output "networks" { value = { for key, instance in module.vpc_network : key => instance.self_link } }
