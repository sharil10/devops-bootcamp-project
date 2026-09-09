#!/bin/bash
set -e

sudo apt-get update -y
sudo apt-get install -y ansible

sudo mkdir -p /etc/ansible
sudo tee /etc/ansible/ansible.cfg > /dev/null <<'EOF'
[defaults]
host_key_checking = False
inventory = /home/ubuntu/ansible/inventory.ini
EOF

sudo mkdir -p /home/ubuntu/ansible