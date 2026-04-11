

resource "aws_route_table" "lab_public_rt" {
  depends_on = [aws_internet_gateway.lab_igw]
  vpc_id     = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_igw.id
  }

  tags = {
    Name = var.names.public_rt
  }
}

resource "aws_route_table" "lab_private_rt" {
  depends_on = [aws_nat_gateway.lab_nat]

  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.lab_nat.id
  }

  tags = {
    Name = var.names.private_rt
  }
}