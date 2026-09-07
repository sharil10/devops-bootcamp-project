#!/bin/bash
# Install AWS Systems Manager Agent (SSM) on Ubuntu 24.04
curl -s https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/ubuntu_amd64/amazon-ssm-agent.deb -o /tmp/ssm-agent.deb
sudo dpkg -i /tmp/ssm-agent.deb
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

apt-get update -y
apt-get install -y curl wget unzip