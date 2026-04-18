locals {
  primary_master_ip      = var.master_config.private_ips[0]
  control_plane_endpoint = "${var.nginx_config.private_ip}:6443"
}
