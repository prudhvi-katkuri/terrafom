provider "aws" {
  region = "us-east-2"
  profile = "mycredentials"
}

terraform {
  backend "s3" {
    profile = "mycredentianls"
    bucket = "terraformstatecode"
    key = "vpc/terraform.tfstate"
    region = "us-east-2"
    profile = "mycredentials"
  }
}


#creating a vpc
resource "aws_vpc" "demovpc" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "demovpc"
  }
}

#creating public subnet
resource "aws_subnet" "public01" {
  vpc_id     = aws_vpc.demovpc.id
  cidr_block = "10.10.1.0/24"

  tags = {
    Name = "public01"
  }
}
#creating public subnet
resource "aws_subnet" "public02" {
  vpc_id     = aws_vpc.demovpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "public02"
  }
}

#creating private subnet
resource "aws_subnet" "private01" {
  vpc_id     = aws_vpc.demovpc.id
  cidr_block = "10.10.3.0/24"

  tags = {
    Name = "private01"
  }
}

#creating private subnet
resource "aws_subnet" "private02" {
  vpc_id     = aws_vpc.demovpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "private02"
  }
}

#creating internet gateway 

resource "aws_internet_gateway" "demoGW" {
  vpc_id = aws_vpc.demovpc.id

  tags = {
    Name = "demoGW"
  }
}

#creating elastic ip 
resource "aws_eip" "eip" {
  vpc      = true
}

#creating nat nat gateway
resource "aws_nat_gateway" "NGW" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public01.id

  tags = {
    Name = "NGW"
  }
}

#creating public route table
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.demovpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demoGW.id
  }

  tags = {
    Name = "public-route"
  }
}

#creating private route table
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.demovpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NGW.id
  }

  tags = {
    Name = "private-route"
  }
}

resource "aws_route_table_association" "a1" {
  subnet_id      = aws_subnet.public01.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "a2" {
  subnet_id      = aws_subnet.public02.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "a3" {
  subnet_id      = aws_subnet.private01.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_route_table_association" "a4" {
  subnet_id      = aws_subnet.private02.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_security_group" "demo_sg" {
  name   = "demo-sg"
  vpc_id = aws_vpc.demovpc.id

   tags = {
    Name = "demo-sg"
  }
}

# Ingress Security rule for Port 22
resource "aws_security_group_rule" "ssh_inbound_access" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.demo_sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = [aws_vpc.demovpc.cidr_block]
}

# Ingress Security rule for Port 80
resource "aws_security_group_rule" "http_inbound_access" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.demo_sg.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = [aws_vpc.demovpc.cidr_block]
}

# All OutBound Access
resource "aws_security_group_rule" "all_outbound_access" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.demo_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

