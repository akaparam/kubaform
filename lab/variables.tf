variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "public_key_for_key_pair" {
  type        = string
  description = "Let's you connect to lab_instance's by allowing your public key"
}

variable "kubeapi_public_hostname" {
  type        = string
  description = "Public hostname used by kubectl clients to reach Kubernetes API through NGINX (example: lab.param.sh)"
  default     = null
}
