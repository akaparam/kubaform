

resource "aws_vpc" "lab_vpc" {
  cidr_block = var.vpc_cidr_block

  enable_dns_hostnames = true

  tags = {
    Name = var.names.vpc
  }
}