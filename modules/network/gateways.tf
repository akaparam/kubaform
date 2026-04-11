

resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = var.names.igw
  }
}

resource "aws_nat_gateway" "lab_nat" {
  depends_on = [aws_internet_gateway.lab_igw] # Public nat depends on IGW's availability somewhere

  allocation_id = aws_eip.lab_nat_ip.id
  subnet_id     = aws_subnet.lab_public_subnets[0].id

  tags = {
    Name = var.names.nat
  }
}