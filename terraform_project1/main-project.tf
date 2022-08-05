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

##create the vpc with specified cidr block  
resource "aws_vpc" "t7m-project-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "t7m-project-vpc"
  }
}

##creates the first public subnet
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

##creates second public subnet
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

##creates the first private subnet 
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

##creates the second private subnet
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

##creates an internet gateway to give our subnets access to internet
resource "aws_internet_gateway" "t7m-ig" {
  vpc_id = aws_vpc.t7m-project-vpc.id
  tags = {
    Name = "t7m-ig"
  }
}

##creates our route table and associates it with our vpc
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

##associate the route table to the public subnets
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.t7m-public-subnet1a.id
  route_table_id = aws_route_table.t7m-public-rt.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.t7m-public-subnet1b.id
  route_table_id = aws_route_table.t7m-public-rt.id
}

##-----------------Instances for ubuntu server, database and security groups
##creates a security group for our public instances
resource "aws_security_group" "t7m-public-sg" {
  name        = "t7m-public-sg"
  description = "Allow inbound traffic on port 80 and 22"
  vpc_id      = aws_vpc.t7m-project-vpc.id

  ingress {
    description = "Http access"
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

##creates an ubuntu ec2 in first public subnet
resource "aws_instance" "t7m-ubuntu" {
  ami                    = "ami-052efd3df9dad4825"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.t7m-public-subnet1a.id
  vpc_security_group_ids = [aws_security_group.t7m-public-sg.id]
  key_name               = "EC2sshkey" ##using an existing keypair
  user_data              = <<-EOF
        #!/bin/bash
        sudo apt update -y
        sudo apt install apache2 -y
        sudo service apache2 start
        echo "<html><body><h1>What's up Ubuntu One</h1></body></html>" > /var/www/html/index.html
        EOF

  tags = {
    Name = "t7m-ubuntu"
  }
}

##creates an ubuntu ec2 in second public subnet
resource "aws_instance" "t7m-ubuntu2" {
  ami                    = "ami-052efd3df9dad4825"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.t7m-public-subnet1b.id
  vpc_security_group_ids = [aws_security_group.t7m-public-sg.id]
  key_name               = "EC2sshkey"
  user_data              = <<-EOF
        #!/bin/bash
        sudo apt update -y
        sudo apt install apache2 -y
        sudo service apache2 start
        echo "<html><body><h1>What's up Ubuntu Two</h1></body></html>" > /var/www/html/index.html
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

##creates a security group for the private subnets
resource "aws_security_group" "t7m-private-sg" {
  name        = "t7m-private-sg"
  description = "Allows web-tier ssh traffic"
  vpc_id      = aws_vpc.t7m-project-vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/16"]
    security_groups = [aws_security_group.t7m-public-sg.id]
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.t7m-public-sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##create database instance
resource "aws_db_instance" "t7mdb" {
  allocated_storage    = 5 ##reduced the allocated_storage to 5 to speed up build time
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  identifier           = "t7mdb"
  db_name              = "t7mdb" ##could not use hyphen in name
  username             = "admin"
  password             = "password" ##password must be 8 characters long
  db_subnet_group_name = aws_db_subnet_group.t7m-db-subnet.id
  publicly_accessible  = false
  skip_final_snapshot  = true
}

##-----------------create an application load balancer and security group
##create the application load balancer 
resource "aws_lb" "t7m-project-alb" {
  name               = "t7m-project-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.t7m-alb-sg.id]
  subnets            = [aws_subnet.t7m-public-subnet1a.id, aws_subnet.t7m-public-subnet1b.id]
}

##create target group for load balancer
resource "aws_lb_target_group" "t7m-project-tg" {
  name       = "project-tg"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = aws_vpc.t7m-project-vpc.id
  depends_on = [aws_vpc.t7m-project-vpc]
}

##create target group attachments for each ubuntu server
resource "aws_lb_target_group_attachment" "attach-ubuntu-1" {
  target_group_arn = aws_lb_target_group.t7m-project-tg.arn
  target_id        = aws_instance.t7m-ubuntu.id
  port             = 80
  depends_on       = [aws_instance.t7m-ubuntu]
}

resource "aws_lb_target_group_attachment" "attach-ubuntu-2" {
  target_group_arn = aws_lb_target_group.t7m-project-tg.arn
  target_id        = aws_instance.t7m-ubuntu2.id
  port             = 80
  depends_on       = [aws_instance.t7m-ubuntu2]
}

##create the application load balancer listener
resource "aws_lb_listener" "t7m-listener" {
  load_balancer_arn = aws_lb.t7m-project-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.t7m-project-tg.arn
  }
}
##create security group for the application load balancer
resource "aws_security_group" "t7m-alb-sg" {
  name        = "t7m-alb-sg"
  description = "security group for alb"
  vpc_id      = aws_vpc.t7m-project-vpc.id

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}






