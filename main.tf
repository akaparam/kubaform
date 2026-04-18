module "network" {
  source = "./modules/network"
}

resource "namecheap_domain_records" "nginx_eip_domain_mapping" {
  depends_on = [module.network]
  domain     = var.root_domain
  mode       = "MERGE"

  count = var.root_domain == null ? 0 : length(var.list_of_subdomains)

  record {
    hostname = var.list_of_subdomains[count.index]
    type     = "A"
    address  = module.network.nginx_eip_public_ip
    ttl      = 300
  }
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
