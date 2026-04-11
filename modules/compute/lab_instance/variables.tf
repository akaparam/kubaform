variable "instance_name" {
  type    = string
  default = "lab_instance"
}

variable "instance_type" {
  type        = string
  description = "Type of instance"
}

variable "ami_type" {
  description = "amazon-linux or ubuntu"
  type        = string
  default     = "amazon-linux"
  validation {
    condition     = var.ami_type == "amazon-linux" || var.ami_type == "ubuntu"
    error_message = "Value must be either `amazon-linux` or `ubuntu`"
  }
}

variable "subnet_id" {
  description = "Subnet Id for the VM"
}

variable "associate_public_ip_address" {
  type        = bool
  default     = false
  description = "Associate a public IPv4 address on launch. Keep false for private subnets."
}

variable "enable_force_destroy" {
  type        = bool
  default     = false
  description = "Will skip OS shutdown and other things. (Default: false)"
}

variable "key_pair_name" {
  type        = string
  default     = null
  description = "If you want to connect to the EC2 instances manually via your local machine, you should attach a key pair"
}

variable "private_ip" {
  type        = string
  default     = null
  description = "Manually assign a static private IP to the instance"
}

variable "security_group_ids" {
  type        = list(string)
  default     = null
  description = "Attach security group(s), or this will default to VPC's security group"
}

variable "user_data" {
  type        = string
  default     = null
  description = "Custom scripts to execute on first launch. MAKE SURE TO `base64encode()` BEFORE PASSING"
}

variable "enable_spot_instances" {
  type        = bool
  default     = false
  description = "TODO"
}

variable "enable_storage_encryption" {
  type    = bool
  default = true
}

variable "storage_type" {
  type    = string
  default = "gp2"
  validation {
    condition     = var.storage_type == "standard" || var.storage_type == "gp2" || var.storage_type == "gp3" || var.storage_type == "io1" || var.storage_type == "io2" || var.storage_type == "sc1" || var.storage_type == "st1"
    error_message = "Value not supported"
  }
}

variable "storage_size" {
  type        = number
  description = "Enter storage size in GiB"
  default     = 10
}
