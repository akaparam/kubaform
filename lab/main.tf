module "network" {
  source = "./modules/network"
}

module "compute" {
  depends_on = [module.network]
  source     = "./modules/compute"

  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids

  nodes_sg_id = module.network.nodes_sg_id
  nginx_sg_id = module.network.nginx_sg_id

  nginx_eip_id = module.network.nginx_eip_id

  public_key_for_key_pair = var.public_key_for_key_pair
  kubeapi_public_hostname = var.kubeapi_public_hostname
}
