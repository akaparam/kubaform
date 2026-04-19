

module "workers" {
  source = "./lab_instance"
  count  = var.worker_config.number_of_instances

  instance_name      = "${var.worker_config.prefix}-${count.index + 1}"
  ami_type           = var.worker_config.ami_type
  instance_type      = var.worker_config.instance_type
  subnet_id          = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  security_group_ids = [var.nodes_sg_id]

  storage_type              = var.worker_config.storage_type
  storage_size              = var.worker_config.storage_size
  enable_storage_encryption = var.worker_config.enable_storage_encryption

  private_ip    = var.worker_config.private_ips[count.index % var.worker_config.number_of_instances]
  key_pair_name = aws_key_pair.lab_key_pair.key_name # Required for connecting through local notebook with nginx as a jumphost

  user_data = base64encode(
    replace(
      file("${path.root}/${var.worker_config.user_data}"),
      "__PRIMARY_MASTER_IP__",
      local.primary_master_ip
    )
  )
}
