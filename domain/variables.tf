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

  validation {
    condition     = var.root_domain != "" || length(var.list_of_subdomains) == 0
    error_message = "root_domain must be set when list_of_subdomains contains values."
  }
}

variable "list_of_subdomains" {
  type        = list(string)
  description = "The list of subdomains to map to the lab IP."
  default     = []

  validation {
    condition     = length(var.list_of_subdomains) == 0 || var.root_domain != ""
    error_message = "list_of_subdomains must be empty unless root_domain is also set."
  }
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