resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "devops-vpc"
  }
}

resource "aws_subnet" "my_public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/25"
  availability_zone       = var.az
  map_public_ip_on_launch = true
  tags = {
    Name = "devops-public-subnet "
  }
}

# --- Private Subnet ---
resource "aws_subnet" "my_private_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.128/25"
  availability_zone       = var.az
  map_public_ip_on_launch = false

  tags = {
    Name = "devops-private-subnet"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "devops-igw"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  

  tags = {
    Name = "devops-nat-eip"
  }
}

# NAT Gateway (located in public subnet)
resource "aws_nat_gateway" "my_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.my_public_subnet.id

  tags = {
    Name = "devops-ngw"
  }

  depends_on = [aws_internet_gateway.my_igw]
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "devops-public-route"
  }
}
resource "aws_route" "my_route" {
  route_table_id         = aws_route_table.my_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}
resource "aws_route_table_association" "my_link" {
  subnet_id      = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# --- Route Table Private ---
resource "aws_route_table" "my_private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "devops-private-route"
  }
}

resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.my_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my_nat.id
}


# --- Private Route Table Association ---
resource "aws_route_table_association" "my_link_private" {
  subnet_id      = aws_subnet.my_private_subnet.id
  route_table_id = aws_route_table.my_private_route_table.id
}
