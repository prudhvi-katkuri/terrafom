provider "aws" {
  region = "us-east-2"
  profile = "default"
}

terraform {
  backend "s3" {
    profile = "default"
    bucket = "terraformstatecode"
    key = "vpc/terraform.tfstate"
    region = "us-east-2"
    
  }
}

# Query all avilable Availibility Zone.
data "aws_availability_zones" "available" {}

#creating a vpc
resource "aws_vpc" "demovpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "demovpc"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = 2
  cidr_block              = var.public_cidrs[count.index]
  vpc_id                  = aws_vpc.demovpc.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "public_subnet.${count.index + 1}"
  }
}


resource "aws_subnet" "private_subnet" {
  count                   = 2
  cidr_block              = var.public_cidrs[count.index]
  vpc_id                  = aws_vpc.demovpc.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private_subnet.${count.index + 1}"
  }
}


#creating internet gateway 

resource "aws_internet_gateway" "demoGW" {
  vpc_id = aws_vpc.demovpc.id

  tags = {
    Name = "demoGW"
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


#creating elastic ip 
resource "aws_eip" "eip" {
  vpc      = true
}

#creating nat nat gateway
resource "aws_nat_gateway" "NGW" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet.0.id

  tags = {
    Name = "NGW"
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

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_subnet_assoc" {
  count          = 2
  route_table_id = aws_route_table.public_route.id
  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
  depends_on     = [aws_route_table.public_route, aws_subnet.public_subnet]
}

# Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private_subnet_assoc" {
  count          = 2
  route_table_id = aws_route_table.private_route.id
  subnet_id      = aws_subnet.private_subnet.*.id[count.index]
  depends_on     = [aws_route_table.private_route, aws_subnet.private_subnet]
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

