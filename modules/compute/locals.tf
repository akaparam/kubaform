locals {
  primary_master_ip      = var.master_config.private_ips[0]
  control_plane_endpoint = "${var.nginx_config.private_ip}:6443"
  control_plane_host     = split(":", local.control_plane_endpoint)[0]
  kubeapi_cert_sans_csv = join(
    ",",
    distinct(
      compact(
        concat(
          [local.control_plane_host],
          var.kubeapi_public_hostname == null ? [] : [var.kubeapi_public_hostname]
        )
      )
    )
  )
}
