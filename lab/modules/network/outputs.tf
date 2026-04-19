output "vpc_id" {
  value = aws_vpc.lab_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.lab_public_subnets.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.lab_private_subnets.*.id
}

output "nginx_eip_id" {
  value = aws_eip.lab_nginx_ip.id
}

output "nginx_eip_public_ip" {
  value = aws_eip.lab_nginx_ip.public_ip
}

output "nodes_sg_id" {
  value = aws_security_group.lab_nodes_sg.id
}

output "nginx_sg_id" {
  value = aws_security_group.lab_nginx_sg.id
}

output "names" {
  value = {
    vpc = aws_vpc.lab_vpc.tags_all["Name"]
    public_subnets = [
      for subnet in aws_subnet.lab_public_subnets :
      lookup(subnet.tags_all, "Name", null)
    ]
    private_subnets = [
      for subnet in aws_subnet.lab_private_subnets :
      lookup(subnet.tags_all, "Name", null)
    ]
    igw        = aws_internet_gateway.lab_igw.tags_all["Name"]
    nat        = aws_nat_gateway.lab_nat.tags_all["Name"]
    nat_eip    = aws_eip.lab_nat_ip.tags_all["Name"]
    nginx_eip  = aws_eip.lab_nginx_ip.tags_all["Name"]
    public_rt  = aws_route_table.lab_public_rt.tags_all["Name"]
    private_rt = aws_route_table.lab_private_rt.tags_all["Name"]
    sg_nodes   = aws_security_group.lab_nodes_sg.tags_all["Name"]
    sg_nginx   = aws_security_group.lab_nginx_sg.tags_all["Name"]
  }
}