

module "nginx" {
  source = "./lab_instance"

  instance_name = "kf-nginx"
  ami_type      = var.nginx_config.ami_type
  instance_type = var.nginx_config.instance_type
  subnet_id     = var.public_subnet_ids[0]
  security_group_ids = [ var.nginx_sg_id ]

  storage_type              = var.nginx_config.storage_type
  storage_size              = var.nginx_config.storage_size
  enable_storage_encryption = var.nginx_config.enable_storage_encryption

  private_ip    = var.nginx_config.private_ip
  key_pair_name = var.nginx_config.key_pair_name

  user_data = base64encode(file("${path.root}/${var.nginx_config.user_data}"))
}

resource "aws_eip_association" "eip_assoc" {
    instance_id = module.nginx.instance_id
    allocation_id = var.nginx_eip_id
}