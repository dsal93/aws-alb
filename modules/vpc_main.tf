# Creating VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "Two-Tier-VPC"
  }
}


#Deploy Subnets
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr[count.index]
  count                   = 2
  map_public_ip_on_launch = true
  availability_zone       = var.AZ[count.index]

  tags = {
    Name = "Public_Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidr[count.index]
  count             = 2
  availability_zone = var.AZ[count.index]

  tags = {
    Name = "Private_Subnet"
  }
}


# creating internet gateway 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "tf_igw"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  connectivity_type = "public"
  subnet_id         = aws_subnet.public_subnet[0].id
  allocation_id     = aws_eip.eip_nat_gateway.id
  tags = {
    Name = "NAT_GW"
  }
}

resource "aws_eip" "eip_nat_gateway" {
  depends_on = [aws_internet_gateway.igw]
  vpc        = true

  tags = {
    Name = "EIP"
  }
}


# Creating Route Tables
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "private_route_table"
  }
}


# Associate route table to the public subnets 
resource "aws_route_table_association" "public_route_assoc" {
  subnet_id      = aws_subnet.public_subnet[count.index].id
  count          = 2
  route_table_id = aws_route_table.public_route_table.id
}


# Associate route table to the private subnets 
resource "aws_route_table_association" "private_route_assoc" {
  subnet_id      = aws_subnet.private_subnet[count.index].id
  count          = 2
  route_table_id = aws_route_table.private_route_table.id
}

# Create security groups 

# Vpc security group 
resource "aws_security_group" "alb_sg" {
  name        = "web_sg"
  description = "allow inbound HTTP traffic"
  vpc_id      = aws_vpc.vpc.id

  # HTTP from vpc
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # outbound rules
  # internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "web_sg"
  }
}


# web tier security group
resource "aws_security_group" "webtier_sg" {
  name        = "webtier_sg"
  description = "allow inbound traffic from ALB"
  vpc_id      = aws_vpc.vpc.id

  # allow inbound traffic from web
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "webserver_sg"
  }
}