output "private_ip" {
  value = aws_instance.lab_instance.private_ip
}

output "instance_id" {
  value = aws_instance.lab_instance.id
}

output "public_ip" {
  value = aws_instance.lab_instance.public_ip
}