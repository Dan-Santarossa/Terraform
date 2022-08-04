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
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "t7m-public-subnet1a"
  }
}
##this block creates second public subnet
resource "aws_subnet" "public-subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "t7m-public-subnet1b"
  }
}
##this block creates the first private subnet 
resource "aws_subnet" "private-subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "t7m-private-subnet1c"
  }  
}
resource "aws_subnet" "private-subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1d"
  tags = {
    Name = "t7m-private-subnet1d"
  }  
}