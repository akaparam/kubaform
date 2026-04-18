

module "masters" {
  source = "./lab_instance"
  count  = var.master_config.number_of_instances

  instance_name      = "${var.master_config.prefix}-${count.index + 1}"
  ami_type           = var.master_config.ami_type
  instance_type      = var.master_config.instance_type
  subnet_id          = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  security_group_ids = [var.nodes_sg_id]

  storage_type              = var.master_config.storage_type
  storage_size              = var.master_config.storage_size
  enable_storage_encryption = var.master_config.enable_storage_encryption

  private_ip    = var.master_config.private_ips[count.index % var.master_config.number_of_instances]
  key_pair_name = aws_key_pair.lab_key_pair.key_name # Required for connecting through local notebook with nginx as a jumphost

  user_data = base64encode(
    replace(
      replace(
        replace(
          file("${path.root}/${var.master_config.user_data}"),
          "__PRIMARY_MASTER_IP__",
          local.primary_master_ip
        ),
        "__CONTROL_PLANE_ENDPOINT__",
        local.control_plane_endpoint
      ),
      "__APISERVER_CERT_EXTRA_SANS__",
      local.kubeapi_cert_sans_csv
    )
  )
}
