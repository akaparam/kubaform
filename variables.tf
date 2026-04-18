variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "public_key_for_key_pair" {
  type        = string
  description = "Let's you connect to lab_instance's by allowing your public key"
}

variable "root_domain" {
  type        = string
  description = "Enter domain_name if you want namecheap to perform the DNS mapping"
  default     = null
}
variable "list_of_subdomains" {
  type        = list(string)
  description = "Define list of records that should be updated with namecheap servers. (REQUIRED) If root_domain is set."

  default = null
}

variable "kubeapi_public_hostname" {
  type        = string
  description = "Public hostname used by kubectl clients to reach Kubernetes API through NGINX (example: lab.param.sh)"
  default     = null
}

variable "namecheap_user_name" {
  type = string
}

variable "namecheap_api_user" {
  type = string
}

variable "namecheap_api_key" {
  type = string
}
