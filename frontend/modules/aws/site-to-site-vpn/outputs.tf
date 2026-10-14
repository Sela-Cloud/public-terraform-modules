output "site_to_site_vpn" {
  description = "Map of all created Site-to-Site VPN connections and their non-sensitive attributes. Excludes customer_gateway_configuration and the tunnel pre-shared keys, which the child module marks sensitive -- see their own outputs below if a consumer specifically needs them."
  value = {
    for k, v in module.site_to_site_vpn : k => {
      customer_gateway_id  = v.customer_gateway_id
      customer_gateway_arn = v.customer_gateway_arn
      vpn_connection_id    = v.vpn_connection_id
      vpn_connection_arn   = v.vpn_connection_arn
      tunnel1_address      = v.tunnel1_address
      tunnel2_address      = v.tunnel2_address
      routes               = v.routes
    }
  }
}

output "customer_gateway_configuration" {
  description = "Map of VPN connection names to their customer gateway configuration XML."
  value       = { for k, v in module.site_to_site_vpn : k => v.customer_gateway_configuration }
  sensitive   = true
}

output "tunnel1_preshared_key" {
  description = "Map of VPN connection names to their first tunnel's pre-shared key."
  value       = { for k, v in module.site_to_site_vpn : k => v.tunnel1_preshared_key }
  sensitive   = true
}

output "tunnel2_preshared_key" {
  description = "Map of VPN connection names to their second tunnel's pre-shared key."
  value       = { for k, v in module.site_to_site_vpn : k => v.tunnel2_preshared_key }
  sensitive   = true
}
