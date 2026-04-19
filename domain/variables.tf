variable "domain_provider" {
  type        = string
  default     = "namecheap"
  description = "Select the domain provider to use for DNS mapping."

  validation {
    condition     = contains(["namecheap"], var.domain_provider)
    error_message = "domain_provider allowed values include: [\"namecheap\"]"
  }
}

variable "root_domain" {
  type        = string
  description = "The domain name to update records for."
  default     = ""
}

variable "list_of_subdomains" {
  type        = list(string)
  description = "The list of subdomains to map to the lab IP."
  default     = []
}

variable "namecheap_user_name" {
  type        = string
  description = "Namecheap API user name."
  default     = ""
}

variable "namecheap_api_user" {
  type        = string
  description = "Namecheap API user."
  default     = ""
}

variable "namecheap_api_key" {
  type        = string
  description = "Namecheap API key."
  default     = ""
}
variable "lab_state_bucket" {
  type    = string
  default = "kf-states"
}

variable "lab_state_key" {
  type    = string
  default = "lab.tfstate"
}

variable "lab_state_region" {
  type    = string
  default = "ap-south-1"
}

variable "lab_state_use_lockfile" {
  type    = bool
  default = true
}