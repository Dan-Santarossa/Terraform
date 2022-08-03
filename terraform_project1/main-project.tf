terraform{
    required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.16"
    }
  }

required_version = ">= 1.2.0"
 
}
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "t7m-project-vpc"
  }
}
resource "aws_subnet" "public-subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "t7m-public-subnet1"
  }
}
resource "aws_subnet" "public-subnet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "t7m-public-subnet2"
  }
}