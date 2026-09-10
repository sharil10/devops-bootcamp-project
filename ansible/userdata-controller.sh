#!/bin/bash
set -e

# Wait for network + apt to be ready (NAT gateway can take time on first boot)
for i in $(seq 1 30); do
  if sudo apt-get update -y >/dev/null 2>&1; then
    break
  fi
  echo "apt-get update failed (attempt $i/30), retrying in 10s..."
  sleep 10
done

# Add Ansible PPA (required for Ubuntu 24.04+)
sudo apt-get install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible

sudo apt-get install -y ansible
sudo snap install aws-cli --classic

sudo mkdir -p /etc/ansible
sudo tee /etc/ansible/ansible.cfg > /dev/null <<'EOF'
[defaults]
host_key_checking = False
inventory = /home/ubuntu/ansible/inventory.ini
EOF

sudo mkdir -p /home/ubuntu/ansible

# Fetch SSH key and inventory from SSM Parameter Store
sudo mkdir -p /home/ubuntu/.ssh
sudo aws ssm get-parameter --name "/devops/ssh-key" --with-decryption --query "Parameter.Value" --output text > /home/ubuntu/.ssh/id_ed25519
sudo chmod 600 /home/ubuntu/.ssh/id_ed25519
sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/id_ed25519

# Also place key for root (SSM runs commands as root)
sudo mkdir -p /root/.ssh
sudo cp /home/ubuntu/.ssh/id_ed25519 /root/.ssh/id_ed25519
sudo chmod 600 /root/.ssh/id_ed25519

sudo aws ssm get-parameter --name "/devops/inventory.ini" --query "Parameter.Value" --output text > /home/ubuntu/ansible/inventory.ini
sudo chown ubuntu:ubuntu /home/ubuntu/ansible/inventory.ini