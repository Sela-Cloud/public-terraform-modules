output "routers" { value = { for key, router in google_compute_router.this : key => router.self_link } }
