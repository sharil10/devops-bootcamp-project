module "public_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 6.0"

  name            = "devops-public-sg"
  use_name_prefix = false
  description     = "Security group for public web server"
  vpc_id          = module.my_vpc.vpc_id

  ingress_rules = {
    http = {
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
    }
    monitoring = {
      cidr_ipv4   = "10.0.0.136/32"
      ip_protocol = "tcp"
      from_port   = 9100
      to_port     = 9100
    }
    ssh = {
      cidr_ipv4   = "${chomp(data.http.myip.response_body)}/32"
      ip_protocol = "tcp"
      from_port   = 22
      to_port     = 22
    }
    ssh_from_controller = {
      cidr_ipv4   = "10.0.0.0/16"
      ip_protocol = "tcp"
      from_port   = 22
      to_port     = 22
    }
  }

  egress_rules = {
    all = {
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "-1"
    }
  }

  tags = {
    Name = "devops-public-sg"
  }
}

module "private_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 6.0"

  name            = "devops-private-sg"
  use_name_prefix = false
  description     = "Security group for private servers monitoring & controller"
  vpc_id          = module.my_vpc.vpc_id

  ingress_rules = {
    ssh = {
      cidr_ipv4   = "${chomp(data.http.myip.response_body)}/32"
      ip_protocol = "tcp"
      from_port   = 22
      to_port     = 22
    }
    ssh_from_bastion = {
      cidr_ipv4   = "10.0.0.0/16"
      ip_protocol = "tcp"
      from_port   = 22
      to_port     = 22
    }
  }

  egress_rules = {
    all = {
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "-1"
    }
  }

  tags = {
    Name = "devops-private-sg"
  }
}

data "http" "myip" {
  url = "https://ifconfig.me/ip"
}