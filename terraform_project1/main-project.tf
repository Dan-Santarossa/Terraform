terraform{
    required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.16"
    }
  }

required_version = ">= 1.2.0"
 
}
##this block creates the vpc for the project
resource "aws_vpc" "t7m-project-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  
  tags = {
    Name = "t7m-project-vpc"
  }
}
##this block creates the first public subnet for vpc
resource "aws_subnet" "public-subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = us-east-1a
  tags = {
    Name = "t7m-public-subnet1"
  }
}
##this block creates second public subnet for vpc
resource "aws_subnet" "public-subnet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = us-east-1b
  tags = {
    Name = "t7m-public-subnet2"
  }
}