##Two tier architecture in AWS 

##Define the provider: Amazon Web Services
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
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
resource "aws_subnet" "private-subnet1" {
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
resource "aws_subnet" "private-subnet2" {
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
    gateway_id = aws_internet_gateway.t7m-ig.id
  }
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