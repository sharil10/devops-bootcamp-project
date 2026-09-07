module "my_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "devops-vpc"
  cidr = "10.0.0.0/24"
  azs  = [var.az]

  # Subnets
  public_subnets  = ["10.0.0.0/25"]
  private_subnets = ["10.0.0.128/25"]

  # Internet Gateway & Public Routing
  create_igw              = true
  map_public_ip_on_launch = true
  public_route_table_tags = {
    Name = "devops-public-route"
  }

  # NAT Gateway & Private Routing
  enable_nat_gateway       = true
  single_nat_gateway       = true
  private_route_table_tags = {
    Name = "devops-private-route"
  }

  # Tags matching original configuration
  igw_tags = {
    Name = "devops-igw"
  }
  nat_gateway_tags = {
    Name = "devops-ngw"
  }
  nat_eip_tags = {
    Name = "devops-nat-eip"
  }

  public_subnet_tags = {
    Name = "devops-public-subnet"
  }
  private_subnet_tags = {
    Name = "devops-private-subnet"
  }

  tags = {
    Name = "devops-vpc"
  }
}