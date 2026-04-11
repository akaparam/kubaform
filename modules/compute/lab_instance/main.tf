locals {
  os = var.ami_type == "ubuntu" ? data.aws_ami.ubuntu.id : data.aws_ami.amazon_linux.id
}

resource "aws_instance" "lab_instance" {
  ami = local.os

  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  force_destroy               = var.enable_force_destroy
  key_name                    = var.key_pair_name
  private_ip                  = var.private_ip
  vpc_security_group_ids      = var.security_group_ids
  user_data_base64            = var.user_data
  # spot_instances

  root_block_device {
    encrypted             = var.enable_storage_encryption
    volume_size           = var.storage_size
    volume_type           = var.storage_type
    delete_on_termination = true
  }

  tags = {
    Name = var.instance_name
  }
}
