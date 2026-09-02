output "vpn_tunnels" {
  value     = { for key, instance in module.vpn_tunnel : key => instance.tunnel_self_link }
  sensitive = true
}
