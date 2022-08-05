##Two tier architecture in AWS 

##Define the provider: Amazon Web Services
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}
##this block creates the vpc 
resource "aws_vpc" "t7m-project-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "t7m-project-vpc"
  }
}
##this block creates the first public subnet
resource "aws_subnet" "t7m-public-subnet1a" {
  vpc_id                  = aws_vpc.t7m-project-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true ##creates a public Ip for the subnet
  tags = {
    Name = "t7m-public-subnet1a"
    Tier = "Public"
  }
}
##this block creates second public subnet
resource "aws_subnet" "t7m-public-subnet1b" {
  vpc_id                  = aws_vpc.t7m-project-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true ##creates a public Ip for the subnet
  tags = {
    Name = "t7m-public-subnet1b"
    Tier = "Public"
  }
}
##this block creates the first private subnet 
resource "aws_subnet" "t7m-private-subnet1c" {
  vpc_id                  = aws_vpc.t7m-project-vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = false ##does not create public Ip for the subnet - keeps it private
  tags = {
    Name = "t7m-private-subnet1c"
    Tier = "Private"
  }
}
##this block creates the second private subnet
resource "aws_subnet" "t7m-private-subnet1d" {
  vpc_id                  = aws_vpc.t7m-project-vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1d"
  map_public_ip_on_launch = false ##does not create public Ip for the subnet - keeps it private
  tags = {
    Name = "t7m-private-subnet1d"
    Tier = "Private"
  }
}
##this block creates an internet gateway
resource "aws_internet_gateway" "t7m-ig" {
  vpc_id = aws_vpc.t7m-project-vpc.id
  tags = {
    Name = "t7m-ig"
  }
}
##this block creates our route table and associates it with our vpc
resource "aws_route_table" "t7m-public-rt" {
  vpc_id = aws_vpc.t7m-project-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.t7m-ig.id ##gives the route table connection to 
  }                                             ##the internet gateway
  tags = {
    "Name" = "t7m-public-rt"
  }
}
##this block associates the route table to the public subnets
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.t7m-public-subnet1a.id
  route_table_id = aws_route_table.t7m-public-rt.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.t7m-public-subnet1b.id
  route_table_id = aws_route_table.t7m-public-rt.id
}
##this block creates a security group for our public instances
resource "aws_security_group" "t7m-public-sg" {
  name        = "t7m-public-sg"
  description = "Allow inbound traffic on port 80 and 22"
  vpc_id      = aws_vpc.t7m-project-vpc.id

  ingress {
    description = "Http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh into instance"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "t7m-public-sg"
  }
}
##creates and ubuntu ec2 in first public subnet
resource "aws_instance" "t7m-ubuntu" {
  ami                    = "ami-052efd3df9dad4825"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.t7m-public-subnet1a.id
  count                  = 1
  vpc_security_group_ids = [aws_security_group.t7m-public-sg.id]
  key_name               = "EC2sshkey" ##using an existing keypair
  user_data              = <<EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install apache2 -y
  sudo service apache2 start
  EOF

  tags = {
    Name = "t7m-ubuntu"
  }
}
##creates and ubuntu ec2 in second public subnet
resource "aws_instance" "t7m-ubuntu2" {
  ami                    = "ami-052efd3df9dad4825"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.t7m-public-subnet1b.id
  count                  = 1
  vpc_security_group_ids = [aws_security_group.t7m-public-sg.id]
  key_name               = "EC2sshkey"
  user_data              = <<EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install apache2 -y
  sudo service apache2 start
  EOF

  tags = {
    Name = "t7m-ubuntu2"
  }
}
##creates a subnet group for the database which is required 
resource "aws_db_subnet_group" "t7m-db-subnet" {
  name       = "t7m-db-subnet"
  subnet_ids = [aws_subnet.t7m-private-subnet1c.id, aws_subnet.t7m-private-subnet1d.id]
}

##create database instance
resource "aws_db_instance" "t7mdb" {
  allocated_storage    = 5
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  identifier           = "t7mdb"
  db_name              = "t7mdb" ##could not use hyphen in name
  username             = "admin"
  password             = "password"
  db_subnet_group_name = aws_db_subnet_group.t7m-db-subnet.id
  publicly_accessible  = false
  skip_final_snapshot  = true
}








