output "firewalls" {
  description = "Created firewall rule self links by configuration key."
  value       = { for key, rule in google_compute_firewall.this : key => rule.self_link }
}
