resource "azurerm_network_security_group" "nsg" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  dynamic "security_rule" {
    for_each = var.security_rules
    content {
      name                                       = security_rule.value.name
      description                                = security_rule.value.description
      protocol                                   = security_rule.value.protocol
      source_port_range                          = security_rule.value.source_port_ranges != null && length(coalesce(security_rule.value.source_port_ranges, [])) > 0 ? null : coalesce(security_rule.value.source_port_range, "*")
      source_port_ranges                         = security_rule.value.source_port_ranges != null && length(coalesce(security_rule.value.source_port_ranges, [])) > 0 ? security_rule.value.source_port_ranges : null
      destination_port_range                     = security_rule.value.destination_port_ranges != null && length(coalesce(security_rule.value.destination_port_ranges, [])) > 0 ? null : coalesce(security_rule.value.destination_port_range, "*")
      destination_port_ranges                    = security_rule.value.destination_port_ranges != null && length(coalesce(security_rule.value.destination_port_ranges, [])) > 0 ? security_rule.value.destination_port_ranges : null
      source_address_prefix                      = (security_rule.value.source_address_prefixes != null && length(coalesce(security_rule.value.source_address_prefixes, [])) > 0) || (security_rule.value.source_application_security_group_ids != null && length(coalesce(security_rule.value.source_application_security_group_ids, [])) > 0) ? null : coalesce(security_rule.value.source_address_prefix, "*")
      source_address_prefixes                    = security_rule.value.source_address_prefixes != null && length(coalesce(security_rule.value.source_address_prefixes, [])) > 0 ? security_rule.value.source_address_prefixes : null
      source_application_security_group_ids      = security_rule.value.source_application_security_group_ids != null && length(coalesce(security_rule.value.source_application_security_group_ids, [])) > 0 ? security_rule.value.source_application_security_group_ids : null
      destination_address_prefix                 = (security_rule.value.destination_address_prefixes != null && length(coalesce(security_rule.value.destination_address_prefixes, [])) > 0) || (security_rule.value.destination_application_security_group_ids != null && length(coalesce(security_rule.value.destination_application_security_group_ids, [])) > 0) ? null : coalesce(security_rule.value.destination_address_prefix, "*")
      destination_address_prefixes               = security_rule.value.destination_address_prefixes != null && length(coalesce(security_rule.value.destination_address_prefixes, [])) > 0 ? security_rule.value.destination_address_prefixes : null
      destination_application_security_group_ids = security_rule.value.destination_application_security_group_ids != null && length(coalesce(security_rule.value.destination_application_security_group_ids, [])) > 0 ? security_rule.value.destination_application_security_group_ids : null
      access                                     = security_rule.value.access
      priority                                   = security_rule.value.priority
      direction                                  = security_rule.value.direction
    }
  }
}
