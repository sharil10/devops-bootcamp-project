resource "aws_security_group" "public_sg" {
  name        = "devops-public-sg"
  description = "Security group for public web server"
  vpc_id      = aws_vpc.my_vpc.id

  tags = {
    Name = "devops-public-sg"
  }
}

# Inbound: Port 80 from anywhere (0.0.0.0/0)
resource "aws_vpc_security_group_ingress_rule" "public_http" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

# Inbound: Port 9100 (Node Exporter) from Monitoring Server (10.0.0.136/32)
resource "aws_vpc_security_group_ingress_rule" "public_monitoring" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4         = "10.0.0.136/32"
  ip_protocol       = "tcp"
  from_port         = 9100
  to_port           = 9100
}

# Inbound: Port 22 (SSH) from VPC CIDR (10.0.0.0/24)
resource "aws_vpc_security_group_ingress_rule" "public_ssh" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4         = aws_vpc.my_vpc.cidr_block
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

# Outbound: All traffic
resource "aws_vpc_security_group_egress_rule" "public_egress" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "private_sg" {
  name        = "devops-private-sg"
  description = "Security group for private servers monitoring & controller"
  vpc_id      = aws_vpc.my_vpc.id

  tags = {
    Name = "devops-private-sg"
  }
}

# Inbound: Port 22 (SSH) from VPC CIDR (10.0.0.0/24)
resource "aws_vpc_security_group_ingress_rule" "private_ssh" {
  security_group_id = aws_security_group.private_sg.id
  cidr_ipv4         = aws_vpc.my_vpc.cidr_block
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

# Outbound: All traffic (needed for NAT-routed internet access, e.g. package updates, scraping port 9100)
resource "aws_vpc_security_group_egress_rule" "private_egress" {
  security_group_id = aws_security_group.private_sg.id
  cidr_ipv4          = "0.0.0.0/0"
  ip_protocol        = "-1"
}

