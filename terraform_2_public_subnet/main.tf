terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region     = "ap-southeast-2"
  access_key = "aacess_key_aws"
  secret_key = "secret_key"
}

resource "aws_vpc" "prod-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "production" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id
}

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "prod" }
}

resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-southeast-2a"
  tags = { Name = "prod-subnet" }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "allow_web" }
}

# ======= HAPUS RESOURCE ENI MANUAL! =======

# 7. Buat EC2 instance, biarkan AWS assign ENI default
resource "aws_instance" "web-server-instance" {
  count = 2  # <--- dari 1 ke 3
  ami                         = "ami-youraws"
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.subnet-1.id
  associate_public_ip_address = false      # Wajib FALSE jika mau attach EIP manual
  key_name                    = "main-key"
  vpc_security_group_ids      = [aws_security_group.allow_web.id]
  # private_ip                = "10.0.1.50" # optional, untuk static private ip

  user_data = <<-EOF
    #!/bin/bash
    export DEBIAN_FRONTEND=noninteractive
    sudo apt update -y
    sudo apt-get install -y nginx
    sudo bash -c 'echo your very first web server > /var/www/html/index.html'
    sudo systemctl status nginx
    EOF

  tags = { 
    Name = "web-ansible-${count.index + 1}"
    }
}

# 8. Data source untuk ambil ENI default dari instance
data "aws_network_interface" "primary" {
  count = 2
  id    = aws_instance.web-server-instance[count.index].primary_network_interface_id
  depends_on = [aws_instance.web-server-instance]
}

# 9. Attach Elastic IP ke ENI bawaan instance (AUTOMATIC, BEST PRACTICE)
resource "aws_eip" "one" {
  count              = 2
  network_interface  = data.aws_network_interface.primary[count.index].id
  vpc                = true
  depends_on         = [data.aws_network_interface.primary]
}

# 10. Output hasil (public IP & public DNS OTOMATIS, SESUAI EIP)
output "servers_public_ip" {
  value = [for eip in aws_eip.one : eip.public_ip]
}

output "servers_private_ip" {
  value = [for i in aws_instance.web-server-instance : i.private_ip]
}

output "servers_id" {
  value = [for i in aws_instance.web-server-instance : i.id]
}

output "servers_public_dns" {
  value = [for i in aws_instance.web-server-instance : i.public_dns]
}