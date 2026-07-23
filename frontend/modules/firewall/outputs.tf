output "firewalls" { value = { for key, instance in module.firewall : key => instance.self_link } }
