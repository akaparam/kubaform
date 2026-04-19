

locals {
  azs             = data.aws_availability_zones.available.names
  public_subnets  = var.public_subnet_cidr_blocks
  private_subnets = var.private_subnet_cidr_blocks
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "lab_public_subnets" {
  vpc_id = aws_vpc.lab_vpc.id
  count  = length(local.public_subnets)

  cidr_block = local.public_subnets[count.index]

  availability_zone = local.azs[count.index % length(local.azs)]

  tags = {
    Name = "${var.names.public_subnet_prefix}-${substr(local.azs[count.index % length(local.azs)], -1, 1)}"
  }
}

resource "aws_route_table_association" "lab_public_subnets_lab_public_rt_associations" {
  count = length(aws_subnet.lab_public_subnets)

  subnet_id      = aws_subnet.lab_public_subnets[count.index].id
  route_table_id = aws_route_table.lab_public_rt.id
}

resource "aws_subnet" "lab_private_subnets" {
  vpc_id = aws_vpc.lab_vpc.id

  count = length(local.private_subnets)

  cidr_block        = local.private_subnets[count.index]
  availability_zone = local.azs[count.index % length(local.azs)]

  tags = {
    Name = "${var.names.private_subnet_prefix}-${substr(local.azs[count.index % length(local.azs)], -1, 1)}"
  }
}

resource "aws_route_table_association" "lab_private_subnets_lab_private_rt_associations" {
  count = length(aws_subnet.lab_private_subnets)

  subnet_id      = aws_subnet.lab_private_subnets[count.index].id
  route_table_id = aws_route_table.lab_private_rt.id
}
