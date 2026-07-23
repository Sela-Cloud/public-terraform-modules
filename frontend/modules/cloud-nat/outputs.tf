output "nats" { value = { for key, instance in module.cloud_nat : key => instance.id } }
