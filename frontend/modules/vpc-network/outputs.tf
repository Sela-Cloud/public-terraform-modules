output "networks" {
  value = { for key, network in google_compute_network.this : key => network.self_link }
}
