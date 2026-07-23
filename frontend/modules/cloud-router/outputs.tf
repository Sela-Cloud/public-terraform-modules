output "routers" { value = { for key, instance in module.cloud_router : key => instance.self_link } }
