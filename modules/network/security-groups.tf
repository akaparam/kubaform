

resource "aws_security_group" "lab_nodes_sg" {
  name        = var.names.nodes_sg
  description = "Kubernetes nodes communication"
  vpc_id      = aws_vpc.lab_vpc.id

  tags = {
    Name = var.names.nodes_sg
  }
}

# ----------------------------------------------------------

resource "aws_security_group_rule" "nodes_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.lab_nodes_sg.id
  self              = true
}

resource "aws_security_group_rule" "nginx_to_nodes" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.lab_nodes_sg.id
  source_security_group_id = aws_security_group.lab_nginx_sg.id
}

resource "aws_security_group_rule" "nodes_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.lab_nodes_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# ----------------------------------------------------------

resource "aws_security_group" "lab_nginx_sg" {
  name        = var.names.nginx_sg
  description = "SG for Nginx LB"
  vpc_id      = aws_vpc.lab_vpc.id

  tags = {
    Name = var.names.nginx_sg
  }
}

# ----------------------------------------------------------

resource "aws_security_group_rule" "nginx_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.lab_nginx_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "nginx_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lab_nginx_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "nginx_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.lab_nginx_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}