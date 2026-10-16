/******************************************
  AWS EC2 Instance Root Module
 *****************************************/

module "ec2_instance" {
  source   = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/ec2-instance?ref=v0.9.18"
  for_each = var.ec2_instance

  name                                 = coalesce(each.value.name, each.key)
  ami                                  = each.value.ami
  instance_type                        = each.value.instance_type
  key_name                             = each.value.key_name
  vpc_id                               = each.value.vpc_id
  subnet_id                            = each.value.subnet_id
  vpc_security_group_ids               = each.value.vpc_security_group_ids
  associate_public_ip_address          = each.value.associate_public_ip_address
  private_ip                           = each.value.private_ip
  secondary_private_ips                = each.value.secondary_private_ips
  source_dest_check                    = each.value.source_dest_check
  availability_zone                    = each.value.availability_zone
  placement_group                      = each.value.placement_group
  tenancy                              = each.value.tenancy
  host_id                              = each.value.host_id
  cpu_core_count                       = each.value.cpu_core_count
  threads_per_core                     = each.value.threads_per_core
  disable_api_termination              = each.value.disable_api_termination
  disable_api_stop                     = each.value.disable_api_stop
  instance_initiated_shutdown_behavior = each.value.instance_initiated_shutdown_behavior
  iam_instance_profile                 = each.value.iam_instance_profile
  monitoring                           = each.value.monitoring
  ebs_optimized                        = each.value.ebs_optimized
  cpu_credits                          = each.value.cpu_credits
  auto_recovery                        = each.value.auto_recovery
  user_data                            = each.value.user_data != null ? replace(each.value.user_data, "\r", "") : null
  user_data_base64                     = each.value.user_data_base64
  user_data_replace_on_change          = each.value.user_data_replace_on_change
  enable_eip                           = each.value.enable_eip
  eip_tags                             = each.value.eip_tags
  root_block_device                    = each.value.root_block_device
  ebs_block_device                     = each.value.ebs_block_device
  metadata_options                     = each.value.metadata_options
  tags                                 = each.value.tags
  volume_tags                          = each.value.volume_tags
  create_key_pair                      = each.value.create_key_pair
  key_pair_name                        = each.value.key_pair_name
  public_key                           = each.value.public_key
  generate_ssh_key                     = each.value.generate_ssh_key
  ssh_user                             = each.value.ssh_user
  create_security_group                = each.value.create_security_group
  security_group_name                  = each.value.security_group_name
  security_group_description           = each.value.security_group_description
  ssh_cidr_blocks                      = each.value.ssh_cidr_blocks
  security_group_tags                  = each.value.security_group_tags
  instance_market_options              = each.value.instance_market_options
  enable_enclave                       = each.value.enable_enclave
  private_dns_name_options             = each.value.private_dns_name_options
  capacity_reservation_specification   = each.value.capacity_reservation_specification
  ephemeral_block_device               = each.value.ephemeral_block_device
}
