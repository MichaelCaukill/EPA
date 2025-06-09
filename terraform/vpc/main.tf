resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "prod_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "prod_igw"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.aws_availability_a

  tags = {
    Name = "public-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.aws_availability_b

  tags = {
    Name = "public-b"
  }
}

resource "aws_route_table" "prod_public_crt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.open_internet
    gateway_id = aws_internet_gateway.prod_igw.id
  }

  tags = {
    Name = "prod_public_crt"
  }
}

resource "aws_route_table_association" "prod_crta_public_subnet_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.prod_public_crt.id
}

resource "aws_route_table_association" "prod_crta_public_subnet_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.prod_public_crt.id
}