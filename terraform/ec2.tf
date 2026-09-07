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

# ==============================================================================
# 1. Web Server (Public Subnet)
# ==============================================================================

resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.my_ami.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.my_public_subnet.id
  private_ip             = "10.0.0.5"
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  iam_instance_profile   = data.aws_iam_instance_profile.my_ssm_profile.name
  key_name               = "sharil-keypair"
  user_data = file("userdata.sh")


  tags = {
    Name = "web server"
  }
}

# Elastic IP attached to Web Server
resource "aws_eip" "web_eip" {
  domain   = "vpc"
  instance = aws_instance.web_server.id

  tags = {
    Name = "devops-web-eip"
  }
}

resource "aws_instance" "controller" {
  ami                    = data.aws_ami.my_ami.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.my_private_subnet.id
  private_ip             = "10.0.0.135"
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  iam_instance_profile   = data.aws_iam_instance_profile.my_ssm_profile.name
  key_name               = "sharil-keypair"
  user_data = file("userdata.sh")


  tags = {
    Name = "controller"
  }
}



resource "aws_instance" "monitoring" {
  ami                    = data.aws_ami.my_ami.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.my_private_subnet.id
  private_ip             = "10.0.0.136"
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  iam_instance_profile   = data.aws_iam_instance_profile.my_ssm_profile.name
  key_name               = "sharil-keypair"
  user_data = file("userdata.sh")


  tags = {
    Name = "monitoring"
  }
}
