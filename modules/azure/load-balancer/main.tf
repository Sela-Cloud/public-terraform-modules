resource "azurerm_lb" "lb" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  edge_zone           = var.edge_zone
  sku                 = var.sku
  sku_tier            = var.sku_tier
  tags                = var.tags

  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ip_configurations
    content {
      name                                               = frontend_ip_configuration.value.name
      zones                                              = frontend_ip_configuration.value.zones
      subnet_id                                          = frontend_ip_configuration.value.subnet_id
      private_ip_address                                 = frontend_ip_configuration.value.private_ip_address
      private_ip_address_allocation                      = frontend_ip_configuration.value.subnet_id != null ? coalesce(frontend_ip_configuration.value.private_ip_address_allocation, "Dynamic") : null
      private_ip_address_version                         = frontend_ip_configuration.value.subnet_id != null ? coalesce(frontend_ip_configuration.value.private_ip_address_version, "IPv4") : null
      public_ip_address_id                               = frontend_ip_configuration.value.public_ip_address_id
      public_ip_prefix_id                                = frontend_ip_configuration.value.public_ip_prefix_id
      gateway_load_balancer_frontend_ip_configuration_id = frontend_ip_configuration.value.gateway_load_balancer_frontend_ip_configuration_id
    }
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  for_each = { for pool in var.backend_pools : pool.name => pool }

  loadbalancer_id    = azurerm_lb.lb.id
  name               = each.value.name
  virtual_network_id = each.value.virtual_network_id
}

resource "azurerm_lb_probe" "probe" {
  for_each = { for probe in var.health_probes : probe.name => probe }

  loadbalancer_id     = azurerm_lb.lb.id
  name                = each.value.name
  protocol            = coalesce(each.value.protocol, "Tcp")
  port                = each.value.port
  request_path        = each.value.protocol == "Http" || each.value.protocol == "Https" ? each.value.request_path : null
  interval_in_seconds = coalesce(each.value.interval_in_seconds, 15)
  number_of_probes    = coalesce(each.value.number_of_probes, 2)
  probe_threshold     = each.value.probe_threshold
}

resource "azurerm_lb_rule" "rule" {
  for_each = { for rule in var.load_balancing_rules : rule.name => rule }

  loadbalancer_id                = azurerm_lb.lb.id
  name                           = each.value.name
  protocol                       = coalesce(each.value.protocol, "Tcp")
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  backend_address_pool_ids       = each.value.backend_address_pool_name != null ? [azurerm_lb_backend_address_pool.backend_pool[each.value.backend_address_pool_name].id] : each.value.backend_address_pool_ids
  probe_id                       = each.value.probe_name != null ? azurerm_lb_probe.probe[each.value.probe_name].id : each.value.probe_id
  enable_floating_ip             = coalesce(each.value.enable_floating_ip, false)
  idle_timeout_in_minutes        = coalesce(each.value.idle_timeout_in_minutes, 4)
  load_distribution              = coalesce(each.value.load_distribution, "Default")
  disable_outbound_snat          = coalesce(each.value.disable_outbound_snat, false)
}

resource "azurerm_lb_nat_rule" "nat_rule" {
  for_each = { for nat in var.inbound_nat_rules : nat.name => nat }

  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = each.value.name
  protocol                       = coalesce(each.value.protocol, "Tcp")
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  idle_timeout_in_minutes        = coalesce(each.value.idle_timeout_in_minutes, 4)
  enable_floating_ip             = coalesce(each.value.enable_floating_ip, false)
}
