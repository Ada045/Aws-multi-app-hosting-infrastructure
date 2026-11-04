data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_location)
}

resource "aws_instance" "main" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_1_id
  vpc_security_group_ids = [var.ec2_security_group_id]
  key_name               = aws_key_pair.ssh_key.key_name
  iam_instance_profile   = var.instance_profile_name

  associate_public_ip_address = true

  user_data = file("${path.root}/entry-script.sh")

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "${var.project_name}-server"
  }
}

resource "aws_eip" "main" {
  domain   = "vpc"
  instance = aws_instance.main.id

  tags = {
    Name = "${var.project_name}-server-eip"
  }
}