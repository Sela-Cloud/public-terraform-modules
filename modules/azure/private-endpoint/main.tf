resource "azurerm_private_endpoint" "endpoint" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  subnet_id                     = var.subnet_id
  custom_network_interface_name = var.custom_network_interface_name

  private_service_connection {
    name                              = var.private_service_connection.name
    private_connection_resource_id    = var.private_service_connection.private_connection_resource_id
    private_connection_resource_alias = var.private_service_connection.private_connection_resource_alias
    subresource_names                 = var.private_service_connection.subresource_names
    is_manual_connection              = var.private_service_connection.is_manual_connection
    request_message                   = var.private_service_connection.is_manual_connection ? var.private_service_connection.request_message : null
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_group != null ? [var.private_dns_zone_group] : []
    content {
      name                 = private_dns_zone_group.value.name
      private_dns_zone_ids = private_dns_zone_group.value.private_dns_zone_ids
    }
  }

  dynamic "ip_configuration" {
    for_each = var.ip_configurations
    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      subresource_name   = ip_configuration.value.subresource_name
      member_name        = ip_configuration.value.member_name != null ? ip_configuration.value.member_name : ip_configuration.value.subresource_name
    }
  }

  tags = var.tags

  dynamic "timeouts" {
    for_each = length(keys(var.timeouts)) > 0 ? [var.timeouts] : []
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}
