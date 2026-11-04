output "alb_security_group_id" {
  value = module.security_group.alb_security_group_id
}

output "ec2_security_group_id" {
  value = module.security_group.ec2_security_group_id
}

output "ec2_public_ip" {
  value = module.ec2.public_ip
}