##Two tier architecture in AWS 

#Define the provider: Amazon Web Services
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
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "t7m-project-vpc"
  }
}
##this block creates the first public subnet
resource "aws_subnet" "public-subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "t7m-public-subnet1a"
    Tier = "Public"
  }
}
##this block creates second public subnet
resource "aws_subnet" "public-subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "t7m-public-subnet1b"
    Tier = "Public"
  }
}
##this block creates the first private subnet 
resource "aws_subnet" "private-subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = false
  tags = {
    Name = "t7m-private-subnet1c"
    Tier = "Private"
  }
}
##this block creates the second private subnet
resource "aws_subnet" "private-subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1d"
  map_public_ip_on_launch = false
  tags = {
    Name = "t7m-private-subnet1d"
    Tier = "Private"
  }
}