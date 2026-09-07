data "aws_ami" "my_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

data "aws_iam_instance_profile" "my_ssm_profile" {
  name = "EC2-SSM-Role"
}

# 1. Web Server (Public)
module "web_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.0"

  name                   = "web server"
  ami                    = data.aws_ami.my_ami.id
  instance_type          = "t3.micro"
  subnet_id              = module.my_vpc.public_subnets[0]
  private_ip             = "10.0.0.5"
  create_security_group  = false
  vpc_security_group_ids = [module.public_sg.id]
  iam_instance_profile   = data.aws_iam_instance_profile.my_ssm_profile.name
  key_name               = "sharil-keypair"

  user_data              = templatefile("userdata.sh", {})
  tags                   = { Name = "web server" }
}

# Elastic IP attached to Web Server
resource "aws_eip" "web_eip" {
  domain   = "vpc"
  instance = module.web_server.id

  tags = {
    Name = "devops-web-eip"
  }
}

# 2. Controller (Private)
module "controller" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.0"

  name                   = "controller"
  ami                    = data.aws_ami.my_ami.id
  instance_type          = "t3.micro"
  subnet_id              = module.my_vpc.private_subnets[0]
  private_ip             = "10.0.0.135"
  create_security_group  = false
  vpc_security_group_ids = [module.private_sg.id]
  iam_instance_profile   = data.aws_iam_instance_profile.my_ssm_profile.name
  key_name               = "sharil-keypair"

  user_data              = templatefile("userdata.sh", {})
  tags                   = { Name = "controller" }
}

# 3. Monitoring (Private)
module "monitoring" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.0"

  name                   = "monitoring"
  ami                    = data.aws_ami.my_ami.id
  instance_type          = "t3.micro"
  subnet_id              = module.my_vpc.private_subnets[0]
  private_ip             = "10.0.0.136"
  create_security_group  = false
  vpc_security_group_ids = [module.private_sg.id]
  iam_instance_profile   = data.aws_iam_instance_profile.my_ssm_profile.name
  key_name               = "sharil-keypair"

  user_data              = templatefile("userdata.sh", {})
  tags                   = { Name = "monitoring" }
}