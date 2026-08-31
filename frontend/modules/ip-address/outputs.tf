output "addresses" {
  description = "Reserved IP address value, keyed by resource name."
  value       = { for key, ip in module.ip_address : key => ip.address }
}
