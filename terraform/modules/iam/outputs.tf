output "instance_profile_name" {
  value = aws_iam_instance_profile.ec2.name
}

output "iam_role_arn" {
  value = aws_iam_role.ec2.arn
}