terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  required_version = "1.1.8"
}

provider "aws" {
  region = "eu-north-1"
}

variable "instance_count" {
  default = "3"
}

resource "aws_key_pair" "main" {
  key_name   = "main"
  public_key = file("${path.module}/.ssh/id_rsa.pub")
}

resource "aws_security_group" "riak" {
  name = "riak"

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 8087
    to_port          = 8087
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 8098
    to_port          = 8098
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 4369
    to_port          = 4369
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 6000
    to_port          = 7023
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "riak" {
  count = var.instance_count

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  key_name = "main"
  security_groups = ["riak"]

  tags = {
    Group = "riak"
    Name  = "riak${count.index + 1}"
  }
}

resource "aws_instance" "ycsb" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  key_name = "main"
  security_groups = ["riak"]

  tags = {
    Group = "ycsb"
    Name  = "ycsb1"
  }
}

output "riak_ip_addr" {
  value = aws_instance.riak.*.public_ip
}

output "ycsb_ip_addr" {
  value = aws_instance.ycsb.public_ip
}