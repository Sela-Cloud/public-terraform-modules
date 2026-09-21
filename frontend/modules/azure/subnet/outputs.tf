output "subnets" {
  description = "Map of created Subnets and their attributes."
  value       = module.subnet
}

output "subnet_ids" {
  description = "Map of Subnet names to their Azure resource IDs."

  value = {
    for k, v in module.subnet :
    k => v.id
  }
}

output "subnet_address_prefixes" {
  description = "Map of Subnet names to their configured address prefixes."

  value = {
    for k, v in module.subnet :
    k => v.address_prefixes
  }
}