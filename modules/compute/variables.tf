variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "nginx_sg_id" {
  type = string
}

variable "nodes_sg_id" {
  type = string
}

variable "nginx_eip_id" {
  type = string
}

variable "public_key_for_key_pair" {
  type        = string
  description = "Let's you connect to lab_instance's by allowing your public key"
}

variable "kubeapi_public_hostname" {
  type        = string
  description = "Public DNS name used by clients to connect to Kubernetes API through NGINX"
  default     = null
}

variable "worker_config" {
  type = any
  default = {
    prefix                    = "kf-worker"
    ami_type                  = "amazon-linux"
    number_of_instances       = 4
    instance_type             = "t3a.medium"
    storage_type              = "gp3"
    storage_size              = 10
    user_data                 = "user_data/worker.sh"
    enable_storage_encryption = true
    private_ips               = ["10.1.2.12", "10.1.3.12", "10.1.2.13", "10.1.3.13"]
  }
}

variable "master_config" {
  type = any
  default = {
    prefix                    = "kf-master"
    ami_type                  = "amazon-linux"
    number_of_instances       = 2
    instance_type             = "t3a.small"
    storage_type              = "gp3"
    storage_size              = 10
    user_data                 = "user_data/master.sh"
    enable_storage_encryption = true
    private_ips               = ["10.1.2.11", "10.1.3.11"]
  }
}

variable "nginx_config" {
  type = any
  default = {
    prefix                    = "kf-nginx"
    ami_type                  = "amazon-linux"
    instance_type             = "t3a.micro"
    storage_type              = "gp3"
    storage_size              = 5
    user_data                 = "user_data/nginx.sh"
    enable_storage_encryption = true
    private_ip                = "10.1.1.10"
  }
}

variable "enable_force_destroy" {
  type    = bool
  default = false
}

variable "use_spot_instances" {
  type    = bool
  default = false
}
