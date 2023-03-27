# Create new vpc
resource "aws_vpc" "tf-vpc" {
  cidr_block       = "10.0.0.0/16"

    tags = {
    Name = "tf-vpc"
  }
}

# Create new subnet
resource "aws_subnet" "tf-subnet" {
  vpc_id     = aws_vpc.tf-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "tf-subnet"
  }
}

# Create new security group

resource "aws_security_group" "tf-sg" {
  name        = "tf-sg"
  description = "Allow incoming traffic"
  vpc_id      = aws_vpc.tf-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

 ingress {
    description      = "TLS from VPC"
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

# Create an internet gateway

resource "aws_internet_gateway" "tf-ig" {
  vpc_id = aws_vpc.tf-vpc.id

  tags = {
    Name = "tf-ig"
  }
}

# Create a route table

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

# Associate your route table with your subnet

resource "aws_route_table_association" "tf-rta" {
  subnet_id      = aws_subnet.tf-subnet.id
  route_table_id = aws_route_table.tf-r.id
}

# Create the key pair

resource "aws_key_pair" "tf-key" {
  key_name   = "tf-key"
  public_key = " ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvj9HFcPhPRZMSYs8MXLsq9bElOLe36l5ivJLJyI+ztQRZk4Gcac0UTDT7LLGRikXglAcw17ruhYC8alNCC7bOzZokofLXtCt0mFeDcJivwQ9BzmCyV+3bFQ34SEdWjw5OG+D8MzZ+P6G5PVdxzrAlzD4XLm9RVbo79zWHIsqxji9igOtpw5+DAM0Yfw7Std5kb+rqyT8Ppbkf3NUdgUzmmgSwGJBbDuWj1VpxeJobMHVzIv/PtiKkGQyAusMVy3ju3ltQsiX5Vxq7Ew+MzY9LJfZ0nigLYi+AY8KaxoSRGNVDjxE+TVuwHGD2JhBcKYWrhcem8B6u96EAqBbL7uSP d00393160@desdemona "
}

# Create EC2 instances

resource "aws_instance" "dev" {
instance_type = "t2.micro"
ami = "ami-0557a15b87f6559cf"
key_name = "aws_key_pair.tf-key.key_name"
associate_public_ip_address = true
subnet_id = aws_subnet.tf-subnet.id
vpc_security_group_ids = [aws_security_group.tf-sg.id]
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
instance_type = "t2.micro"
ami = "ami-0557a15b87f6559cf"
key_name = "aws_key_pair.tf-key.key_name"
associate_public_ip_address = true
subnet_id = aws_subnet.tf-subnet.id
vpc_security_group_ids = [aws_security_group.tf-sg.id]
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
instance_type = "t2.micro"
ami = "ami-0557a15b87f6559cf"
key_name = "aws_key_pair.tf-key.key_name"
associate_public_ip_address = true
subnet_id = aws_subnet.tf-subnet.id
vpc_security_group_ids = [aws_security_group.tf-sg.id]
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

output "instance_public_ip1" {
  description = "Public IP"
  value       = aws_instance.dev.public_ip
}

output "instance_public_ip2" {
  description = "Public IP"
  value       = aws_instance.test.public_ip
}

output "instance_public_ip3" {
  description = "Public IP"
  value       = aws_instance.prod.public_ip
}
