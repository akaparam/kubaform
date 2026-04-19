

# To fetch the lab IP address from the remote state of the lab module.
data "terraform_remote_state" "main" {
  backend = "s3"

  config = {
    bucket       = var.lab_state_bucket
    key          = var.lab_state_key
    region       = var.lab_state_region
    use_lockfile = var.lab_state_use_lockfile
  }
}

locals {
  lab_ip = data.terraform_remote_state.main.outputs.lab_ip
}

resource "namecheap_domain_records" "nginx_eip_domain_mapping" {
  count  = var.domain_provider == "namecheap" ? length(var.list_of_subdomains) : 0
  domain = var.root_domain
  mode   = "MERGE"

  record {
    hostname = var.list_of_subdomains[count.index]
    type     = "A"
    address  = local.lab_ip
    ttl      = 300
  }
}