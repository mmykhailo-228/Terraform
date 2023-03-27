terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.60.0"
    }
  }
}




provider "aws" {
  region  = "us-east-1"
}







resource "aws_vpc" "tf-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "tf-vpc"
  }
}

resource "aws_subnet" "tf-subnet" {
  vpc_id     = aws_vpc.tf-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "tf-subnet"
  }
}

resource "aws_security_group" "tf-sg" {
  name        = "tf-sg"
  description = "allow all incoming traffic to ports 80 and 22"
  vpc_id      = aws_vpc.tf-vpc.id

  ingress {
    description      = "80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  ingress {
    description      = "22"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "tf-sg"
  }
}

resource "aws_internet_gateway" "tf-ig" {
  vpc_id = aws_vpc.tf-vpc.id

  tags = {
    Name = "tf-ig"
  }
}

resource "aws_route_table" "tf-r" {
  vpc_id = aws_vpc.tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-ig.id
  }

  tags = {
     Name = "tf-r"
  }
}

resource "aws_route_table_association" "tf-ra" {
  subnet_id      = aws_subnet.tf-subnet.id
  route_table_id = aws_route_table.tf-r.id
}

resource "aws_key_pair" "tf-key" {
  key_name   = "tf-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvj9HFcPhPRZMSYs8MXLsq9bElOLe36l5ivJLJyI+ztQRZk4Gcac0UTDT7LLGRikXglAcw17ruhYC8alNCC7bOzZokofLXtCt0mFeDcJivwQ9BzmCyV+3bFQ34SEdWjw5OG+D8MzZ+P6G5PVdxzrAlzD4XLm9RVbo79zWHIsqxji9igOtpw5+DAM0Yfw7Std5kb+rqyT8Ppbkf3NUdgUzmmgSwGJBbDuWj1VpxeJobMHVzIv/PtiKkGQyAusMVy3ju3ltQsiX5Vxq7Ew+MzY9LJfZ0nigLYi+AY8KaxoSRGNVDjxE+TVuwHGD2JhBcKYWrhcem8B6u96EAqBbL7uSP d00393160@desdemona"

}
resource "aws_instance" "dev" {
  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.tf-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.tf-sg.id]
  subnet_id = aws_subnet.tf-subnet.id
  user_data = <<-EOF
         #!/bin/bash
         wget http://computing.utahtech.edu/it/3110/notes/2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
         EOF
tags = {
    Name = "dev"
  }
}

resource "aws_instance" "test" {
  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.tf-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.tf-sg.id]
  subnet_id = aws_subnet.tf-subnet.id
  user_data = <<-EOF
         #!/bin/bash
         wget http://computing.utahtech.edu/it/3110/notes/2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
         EOF
tags = {
    Name = "test"
  }
}

resource "aws_instance" "prod" {
  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.tf-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.tf-sg.id]
  subnet_id = aws_subnet.tf-subnet.id
  user_data = <<-EOF
         #!/bin/bash
         wget http://computing.utahtech.edu/it/3110/notes/2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
         EOF
tags = {
    Name = "prod"
  }
}

output "public_ip1" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.dev.public_ip
}

output "public_ip2" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.test.public_ip
}

output "public_ip3" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.prod.public_ip
}
