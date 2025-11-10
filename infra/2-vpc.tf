resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name    = "main_vpc"
    Service = "terraform"
  }
}

resource "aws_subnet" "public_class_6_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  for_each                = var.public_subnet_config
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = {
    Name    = each.key
    Service = "terraform"
    VPC     = "main_vpc"
  }
}


resource "aws_subnet" "splunkapp_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  for_each                = var.private_subnet_config
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = false
  tags = {
    Name    = each.key
    Service = "terraform"
    VPC     = "main_vpc"
  }
}

resource "aws_internet_gateway" "class_6_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name    = "class_6_subnet"
    Service = "terraform"
    VPC     = "main_vpc"
  }
}

resource "aws_eip" "class7_nat_gateway_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.class_6_igw]
  tags = {
    Name = "class7_igw_eip"
  }
}

#Create NAT Gateway
resource "aws_nat_gateway" "class7_nat_gateway" {
  depends_on    = [aws_subnet.public_class_6_subnet]
  allocation_id = aws_eip.class7_nat_gateway_eip.id
  subnet_id     = aws_subnet.public_class_6_subnet["public_class6_subnet_1"].id
  tags = {
    Name = "class7_nat_gateway"
  }
}


resource "aws_route_table" "class_6_public_rtb" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.class_6_igw.id
  }
  tags = {
    Name    = "class_6_public_rtb"
    Service = "terraform"
    VPC     = "main_vpc"
  }
}


resource "aws_route_table" "class_6_private_rtb" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.class7_nat_gateway.id
  }
  tags = {
    Name    = "class_6_splunkapp_rtb"
    Service = "terraform"
    VPC     = "main_vpc"
  }
}


resource "aws_route_table_association" "class_6_public_rtb_association" {
  for_each       = aws_subnet.public_class_6_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.class_6_public_rtb.id
}


resource "aws_route_table_association" "class_6_private_rtb_association" {
  for_each       = aws_subnet.splunkapp_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.class_6_private_rtb.id
}
