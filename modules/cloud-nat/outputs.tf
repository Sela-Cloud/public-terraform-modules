output "nats" { value = { for key, nat in google_compute_router_nat.this : key => nat.id } }
