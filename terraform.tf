terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.39.0"
    }
    namecheap = {
      source  = "namecheap/namecheap"
      version = ">= 2.0.0"
    }
  }

  required_version = "~> 1.14"

  backend "s3" {
    bucket       = "kf-states"
    key          = "terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
  }

  # backend "local" {}
}

provider "aws" {
  region = var.region
}

provider "namecheap" {
  use_sandbox = false
  user_name = var.namecheap_user_name
  api_user = var.namecheap_api_user
  api_key = var.namecheap_api_key
}