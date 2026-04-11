

variable "names" {
  type        = any
  description = "If you like things neat and clean, kindly add naming for the available components"
  default = {
    vpc                   = "kf-vpc"
    public_subnet_prefix  = "kf-public"
    private_subnet_prefix = "kf-private"
    igw                   = "kf-igw"
    nat                   = "kf-nat"
    nat_eip               = "kf-nat-ip"
    nginx_eip             = "kf-nginx-ip"
    public_rt             = "kf-public-rt"
    private_rt            = "kf-private-rt"
    nodes_sg              = "kf-nodes-sg"
    nginx_sg              = "kf-nginx-sg"
  }
}

# VPC
variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

# Subnets
variable "public_subnet_cidr_blocks" {
  type        = list(string)
  description = "Specify the public subnet configuration. Subnets are auto-distributed among available AZs to ensure HA. Defaults to 1."
  default = [
    "10.0.1.0/24"
  ]

  validation {
    condition     = length(var.public_subnet_cidr_blocks) > 0
    error_message = "At least one public subnet CIDR must be provided."
  }
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  description = "Specify the public subnet configuration. Subnets are auto-distributed among available AZs to ensure HA. [Default: \"10.0.2.0/24\", \"10.0.3.0/24\"]"

  default = [
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]
  validation {
    condition     = length(var.private_subnet_cidr_blocks) > 0
    error_message = "At least one private subnet CIDR must be provided."
  }
}