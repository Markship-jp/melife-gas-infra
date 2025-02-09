# Local variables

locals {
  vpc_name                  = "${var.env}-${var.project}-vpc"
  igw_name                  = "${var.env}-${var.project}-igw"
  nat_name_a                = "${var.env}-${var.project}-ngw-1a"
  nat_eip_name_a            = "${var.env}-${var.project}-ngw-eip-1a"
  subnet_pub_app_1a_name    = "${var.env}-${var.project}-public-subnet-app-1a"
  subnet_pub_app_1c_name    = "${var.env}-${var.project}-public-subnet-app-1c"
  subnet_pri_app_1a_name    = "${var.env}-${var.project}-private-subnet-app-1a"
  subnet_pri_app_1c_name    = "${var.env}-${var.project}-private-subnet-app-1c"
  subnet_pri_db_1a_name     = "${var.env}-${var.project}-private-subnet-db-1a"
  subnet_pri_db_1c_name     = "${var.env}-${var.project}-private-subnet-db-1c"
  route_pub_app_1a_name     = "${var.env}-${var.project}-public-route-app-1a"
  route_pub_app_1c_name     = "${var.env}-${var.project}-public-route-app-1c"
  route_pri_app_1a_name     = "${var.env}-${var.project}-private-route-app-1a"
  route_pri_app_1c_name     = "${var.env}-${var.project}-private-route-app-1c"
  route_pri_db_1a_name      = "${var.env}-${var.project}-private-route-db-1a"
  route_pri_db_1c_name      = "${var.env}-${var.project}-private-route-db-1c"
}

# VPC

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = local.vpc_name
  }
}

# Gateway
# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = local.igw_name
  }

}

# NAT Gateway
resource "aws_nat_gateway" "nat_a" {
  allocation_id     = aws_eip.nat_a.id
  subnet_id         = aws_subnet.public_app_1a.id
  connectivity_type = "public"

  tags = {
    Name = local.nat_name_a
  }
}

# EIP for NAT Gateway

resource "aws_eip" "nat_a" {
  domain = "vpc"

  tags = {
    Name = local.nat_eip_name_a
  }
}

# Subnet
# Public subnet 1a for Ingress

resource "aws_subnet" "public_app_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnets["public_app_1a"]
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones["az-1a"]

  tags = {
    Name = local.subnet_pub_app_1a_name
  }
}

# Public subnet 1c for Ingress
resource "aws_subnet" "public_app_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnets["public_app_1c"]
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones["az-1c"]

  tags = {
    Name = local.subnet_pub_app_1c_name
  }
}

# Private Subnet 1a for Application

resource "aws_subnet" "private_app_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnets["private_app_1a"]
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zones["az-1a"]

  tags = {
    Name = local.subnet_pri_app_1a_name
  }
}

# Private Subnet 1c for Application

resource "aws_subnet" "private_app_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnets["private_app_1c"]
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zones["az-1c"]

  tags = {
    Name = local.subnet_pri_app_1c_name
  }
}

# Private Subnet 1a for Database

resource "aws_subnet" "private_db_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnets["private_db_1a"]
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zones["az-1a"]

  tags = {
    Name = local.subnet_pri_db_1a_name
  }
}

# Private Subnet 1c for Database

resource "aws_subnet" "private_db_1c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnets["private_db_1c"]
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zones["az-1c"]

  tags = {
    Name = local.subnet_pri_db_1c_name
  }
}

# Public Route Table
# Route_table

resource "aws_route_table" "public_app_1a" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = local.route_pub_app_1a_name
  }
}

resource "aws_route_table" "public_app_1c" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = local.route_pub_app_1c_name
  }
}

# Route Table Association
resource "aws_route_table_association" "public_app_1a" {
  subnet_id      = aws_subnet.public_app_1a.id
  route_table_id = aws_route_table.public_app_1a.id
}

resource "aws_route_table_association" "public_app_1c" {
  subnet_id      = aws_subnet.public_app_1c.id
  route_table_id = aws_route_table.public_app_1c.id
}

# Route to Internet
resource "aws_route" "public_app_1a" {
  route_table_id         = aws_route_table.public_app_1a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route" "public_app_1c" {
  route_table_id         = aws_route_table.public_app_1c.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Private Route Table(Application)
# Route_table for 

resource "aws_route_table" "private_app_1a" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = local.route_pri_app_1a_name
  }
}

resource "aws_route_table" "private_app_1c" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = local.route_pri_app_1c_name
  }
}

# Route Table Association
resource "aws_route_table_association" "private_app_1a" {
  subnet_id      = aws_subnet.private_app_1a.id
  route_table_id = aws_route_table.private_app_1a.id
}

resource "aws_route_table_association" "private_app_1c" {
  subnet_id      = aws_subnet.private_app_1c.id
  route_table_id = aws_route_table.private_app_1c.id
}

# Route to Internet
resource "aws_route" "private_app_1a" {
  route_table_id         = aws_route_table.private_app_1a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_a.id
}

resource "aws_route" "private_app_1c" {
  route_table_id         = aws_route_table.private_app_1c.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_a.id
}

# Private Route Table(Database)

resource "aws_route_table" "private_db_1a" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = local.route_pri_db_1a_name
  }
}

resource "aws_route_table" "private_db_1c" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = local.route_pri_db_1c_name
  }
}

# Route Table Association(Database)
resource "aws_route_table_association" "private_db_1a" {
  subnet_id      = aws_subnet.private_db_1a.id
  route_table_id = aws_route_table.private_db_1a.id
}

resource "aws_route_table_association" "private_db_1c" {
  subnet_id      = aws_subnet.private_db_1c.id
  route_table_id = aws_route_table.private_db_1c.id
}



