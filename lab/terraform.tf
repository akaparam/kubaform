terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.39.0"
    }
  }

  required_version = "~> 1.14"

  backend "s3" {
    bucket       = "kf-states"
    key          = "lab.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
  }

  # backend "local" {}
}

provider "aws" {
  region = var.region
}
