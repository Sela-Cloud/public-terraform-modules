output "vpc_peerings" {
  description = "Map of created AWS VPC Peering Connection attributes."
  value       = module.vpc_peering
}
