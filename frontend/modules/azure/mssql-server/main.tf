module "mssql_server" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/azure/mssql-server?ref=v0.9.4"
  for_each = var.mssql_server

  name                                 = each.value.name
  resource_group_name                  = each.value.resource_group_name
  location                             = each.value.location
  server_version                       = each.value.server_version
  administrator_login                  = each.value.administrator_login
  administrator_login_password         = each.value.administrator_login_password
  minimum_tls_version                  = each.value.minimum_tls_version
  public_network_access_enabled        = each.value.public_network_access_enabled
  outbound_network_restriction_enabled = each.value.outbound_network_restriction_enabled
  connection_policy                    = each.value.connection_policy
  azuread_administrator                = each.value.azuread_administrator
  identity                             = each.value.identity
  databases                            = each.value.databases
  firewall_rules                       = each.value.firewall_rules
  allow_azure_services_access          = each.value.allow_azure_services_access
  tags                                 = each.value.tags
}
