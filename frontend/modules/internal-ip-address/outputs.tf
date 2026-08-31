output "addresses" {
  description = "Reserved IP address value, keyed by resource name."
  value       = { for key, ip in module.internal_ip_address : key => ip.address }
}
