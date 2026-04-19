

resource "aws_eip" "lab_nat_ip" {
  depends_on = [aws_internet_gateway.lab_igw]

  tags = {
    Name = var.names.nat_eip
  }
}

resource "aws_eip" "lab_nginx_ip" {
  depends_on = [aws_internet_gateway.lab_igw]

  tags = {
    Name = var.names.nginx_eip
  }
}