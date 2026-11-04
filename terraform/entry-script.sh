#!/bin/bash
set -e

# Update system
apt-get update -y
apt-get upgrade -y

# Install required packages
apt-get install -y \
    ca-certificates \
    curl \
    unzip \
    docker.io \
    docker-compose-v2 \
    nginx

# Start Docker
systemctl enable docker
systemctl start docker

# Allow Ubuntu user to run Docker
usermod -aG docker ubuntu

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
    -o "/tmp/awscliv2.zip"

unzip -q /tmp/awscliv2.zip -d /tmp

/tmp/aws/install

rm -rf /tmp/aws /tmp/awscliv2.zip

# Create application directories
mkdir -p /home/ubuntu/sneakers-app
mkdir -p /home/ubuntu/rabbit-lms
mkdir -p /home/ubuntu/django-crm

# Set directory ownership
chown -R ubuntu:ubuntu /home/ubuntu/sneakers-app
chown -R ubuntu:ubuntu /home/ubuntu/rabbit-lms
chown -R ubuntu:ubuntu /home/ubuntu/django-crm

# Start Nginx
systemctl enable nginx
systemctl start nginx

echo "EC2 initialization completed successfully"

# Verify SSM Agent
# Install and start the SSM Agent
if ! snap list amazon-ssm-agent >/dev/null 2>&1; then
  snap install amazon-ssm-agent --classic
fi
snap start --enable amazon-ssm-agent