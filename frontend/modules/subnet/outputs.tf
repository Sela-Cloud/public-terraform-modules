output "subnetworks" { value = { for key, instance in module.subnet : key => instance.self_link } }
