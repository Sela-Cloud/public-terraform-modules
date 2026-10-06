################################################################################
# VPC Endpoints Outputs
################################################################################

output "endpoints" {
  description = "Map of created VPC Endpoints and their attributes."
  value = {
    for k, ep in aws_vpc_endpoint.this : k => {
      id                    = ep.id
      arn                   = ep.arn
      service_name          = ep.service_name
      vpc_endpoint_type     = ep.vpc_endpoint_type
      dns_entry             = ep.dns_entry
      network_interface_ids = ep.network_interface_ids
      prefix_list_id        = ep.prefix_list_id
      cidr_blocks           = ep.cidr_blocks
      owner_id              = ep.owner_id
      requester_managed     = ep.requester_managed
      region                = ep.region
      state                 = ep.state
    }
  }
}

output "endpoint_ids" {
  description = "Map of endpoint keys to their generated VPC Endpoint IDs."
  value       = { for k, ep in aws_vpc_endpoint.this : k => ep.id }
}

output "security_group_id" {
  description = "The ID of the dedicated Security Group created for Interface Endpoints, if enabled."
  value       = try(aws_security_group.this[0].id, null)
}

output "security_group_arn" {
  description = "The ARN of the dedicated Security Group created for Interface Endpoints, if enabled."
  value       = try(aws_security_group.this[0].arn, null)
}
