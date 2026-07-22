output "firewalls" {
  value = { for key, rule in google_compute_firewall.this : key => rule.self_link }
}
