# Set the AWS provider and region
provider "aws" {
  region = "us-east-1"
}

terraform {
    required_version = ">= 1.0.7"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.9.0"
    }
  }
}

# Create the VPC
resource "aws_vpc" "zendrix_vpc" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "zendrix-vpc"
  }
}

# Create two public subnets
resource "aws_subnet" "zendrix_public_subnet_1" {
  vpc_id = aws_vpc.zendrix_vpc.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "zendrix-public-subnet"
  }
}

resource "aws_subnet" "zendrix_public_subnet_2" {
  vpc_id = aws_vpc.zendrix_vpc.id
  cidr_block = "192.168.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "zendrix-public-subnet-2"
  }
}

# Create two private subnets
resource "aws_subnet" "zendrix_private_subnet_1" {
  vpc_id = aws_vpc.zendrix_vpc.id
  cidr_block = "192.168.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "zendrix-private-subnet"
  }
}

resource "aws_subnet" "zendrix_private_subnet_2" {
  vpc_id = aws_vpc.zendrix_vpc.id
  cidr_block = "192.168.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "zendrix-private-subnet-2"
  }
}

# Create the Internet Gateway
resource "aws_internet_gateway" "zendrix_igw" {
  vpc_id = aws_vpc.zendrix_vpc.id
  tags = {
    Name = "zendrix-igw"
  }
}

# Create the NAT Gateway
resource "aws_nat_gateway" "zendrix_nat_gw" {
  allocation_id = aws_eip.zendrix_nat_eip.id
  subnet_id     = aws_subnet.zendrix_public_subnet_1.id

  tags = {
    Name = "zendrix-nat-gw"
  }
}

resource "aws_eip" "zendrix_nat_eip" {
  vpc = true
}

# Create the public route table and add a route to the internet gateway
resource "aws_route_table" "zendrix_public_rt" {
  vpc_id = aws_vpc.zendrix_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.zendrix_igw.id
  }

  tags = {
    Name = "zendrix-public-rt"
  }
}

# Associate the public subnets with the public route table
resource "aws_route_table_association" "public_rt_assoc_1" {
  subnet_id = aws_subnet.zendrix_public_subnet_1.id
  route_table_id = aws_route_table.zendrix_public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc_2" {
  subnet_id = aws_subnet.zendrix_public_subnet_2.id
  route_table_id = aws_route_table.zendrix_public_rt.id
}

# Create the private route table and add a route to the NAT gateway
resource "aws_route_table" "zendrix_private_rt" {
  vpc_id = aws_vpc.zendrix_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.zendrix_nat_gw.id
  }

  tags = {
    Name = "zendrix-private-rt"
  }
}

# Associate the private route table with the private subnet
resource "aws_route_table_association" "zendrix_private_rta_1" {
  subnet_id      = aws_subnet.zendrix_private_subnet_1.id
  route_table_id = aws_route_table.zendrix_private_rt.id
}

resource "aws_route_table_association" "zendrix_private_rta_2" {
  subnet_id      = aws_subnet.zendrix_private_subnet_2.id
  route_table_id = aws_route_table.zendrix_private_rt.id
}

# Create the security group for the web server
resource "aws_security_group" "mywebserver" {
  name = "mywebserver"
  vpc_id      = aws_vpc.zendrix_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mywebserver"
  }
}