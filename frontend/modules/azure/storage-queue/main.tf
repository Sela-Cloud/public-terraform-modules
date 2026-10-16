module "storage_queue" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules.git//modules/azure/storage-queue?ref=v0.9.16"
  for_each = var.storage_queue

  name               = each.value.name
  storage_account_id = each.value.storage_account_id
  metadata           = each.value.metadata
  timeouts           = each.value.timeouts
}
