output "instance_id" {
  value = aws_instance.main.id
}

output "private_ip" {
  value = aws_instance.main.private_ip
}

output "public_ip" {
  value = aws_eip.main.public_ip
}

output "ami_id" {
  value = aws_instance.main.ami
}