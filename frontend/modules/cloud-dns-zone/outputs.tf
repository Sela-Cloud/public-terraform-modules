output "managed_zones" {
  value = {
    for key, zone in module.cloud_dns_zone : key => {
      name         = zone.name
      dns_name     = zone.dns_name
      name_servers = zone.name_servers
    }
  }
}
