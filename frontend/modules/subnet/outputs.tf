output "subnetworks" {
  value = { for key, subnet in google_compute_subnetwork.this : key => subnet.self_link }
}
