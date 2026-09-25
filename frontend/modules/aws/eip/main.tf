/******************************************
  AWS Elastic IP Root Module
 *****************************************/

module "eip" {
  source   = "../../../../modules/aws/eip"
  for_each = var.eip

  name                      = coalesce(each.value.name, each.key)
  domain                    = each.value.domain
  instance                  = each.value.instance
  network_interface         = each.value.network_interface
  associate_with_private_ip = each.value.associate_with_private_ip
  public_ipv4_pool          = each.value.public_ipv4_pool
  network_border_group      = each.value.network_border_group
  customer_owned_ipv4_pool  = each.value.customer_owned_ipv4_pool
  ipam_pool_id              = each.value.ipam_pool_id
  address                   = each.value.address
  tags                      = each.value.tags
}
