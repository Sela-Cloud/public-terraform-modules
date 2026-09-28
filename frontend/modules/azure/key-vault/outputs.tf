output "key_vaults" {
  description = "A map of all created Azure Key Vault module instances."
  value       = module.key_vault
}

output "key_vault_ids" {
  description = "A map of Key Vault names to their respective resource IDs."
  value       = { for k, v in module.key_vault : k => v.id }
}

output "key_vault_uris" {
  description = "A map of Key Vault names to their respective Vault URIs."
  value       = { for k, v in module.key_vault : k => v.vault_uri }
}
