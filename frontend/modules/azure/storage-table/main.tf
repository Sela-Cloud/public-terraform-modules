module "storage_table" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules.git//modules/azure/storage-table?ref=azure-storage-table"
  for_each = var.storage_table

  name               = each.value.name
  storage_account_id = each.value.storage_account_id
  acl                = each.value.acl
  timeouts           = each.value.timeouts
}
