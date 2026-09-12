# DevOps Bootcamp Final Project

**Complete DevOps pipeline with Terraform, Ansible, Docker, Prometheus, Grafana, and Cloudflare.**

---

## 🌐 Live URLs

| Service | URL |
|---------|-----|
| **Application** | [https://web.myvision.asia](https://web.myvision.asia) |
| **Monitoring (Grafana)** | [https://monitoring.myvision.asia](https://monitoring.myvision.asia) |
| **Documentation** | [https://pages.myvision.asia](https://pages.myvision.asia) |
| **GitHub Repository** | [https://github.com/sharil10/devops-bootcamp-project](https://github.com/sharil10/devops-bootcamp-project) |

---

## 🏗️ Architecture

**AWS Region:** ap-southeast-1 (Singapore)

```
VPC: 10.0.0.0/24 (devops-vpc)
├── Public Subnet: 10.0.0.0/25
│   └── Web Server: 10.0.0.5
│       ├── Docker: Ship app on nginx (port 80)
│       ├── node_exporter (port 9100)
│       └── Elastic IP: 13.228.104.254
│
└── Private Subnet: 10.0.0.128/25
    ├── Controller: 10.0.0.135
    │   └── Ansible
    │
    └── Monitoring: 10.0.0.136
        ├── Prometheus (port 9090)
        ├── Grafana (port 3000)
        └── cloudflared tunnel
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| **IaC** | Terraform |
| **Config Mgmt** | Ansible |
| **Container** | Docker (multi-stage build) |
| **Registry** | AWS ECR |
| **Monitoring** | Prometheus + Grafana |
| **Networking** | Cloudflare Tunnel + DNS |
| **Security** | AWS SSM, IAM least privilege |

---

## 📁 Project Structure

```
devops-bootcamp-project/
├── app/                        # Application source + Dockerfile
│   ├── Dockerfile
│   ├── package.json
│   └── src/
├── ansible/                    # Ansible playbooks
│   ├── ansible.cfg
│   ├── docker-playbook.yml
│   ├── playbook-exporter.yml
│   ├── playbook-monitoring.yml
│   ├── app-deploy-playbook.yml
│   └── monitoring/
│       ├── docker-compose.yml
│       └── prometheus.yml
├── terraform/                  # Infrastructure as Code
│   ├── ec2.tf
│   ├── network.tf
│   ├── security.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── inventory.tf
│   └── inventory.ini.tftpl
├── docs/
│   └── screenshots/
└── README.md
```

---

## 🚀 Setup Instructions

### Prerequisites

- AWS account with credentials configured
- Terraform >= 1.5
- Ansible >= 2.16
- Docker
- Domain on Cloudflare

### 1. Provision Infrastructure

```bash
cd terraform
terraform init
terraform apply -auto-approve
```

This creates:
- VPC 10.0.0.0/24 with public + private subnets
- Internet Gateway, NAT Gateway, route tables
- 3 EC2 instances (web, controller, monitoring)
- Security groups (public + private)
- ECR repository

### 2. Configure Controller via AWS SSM

```bash
# Get controller instance ID
cd terraform
terraform output

# Connect to controller (no SSH needed)
aws ssm start-session --target <controller-instance-id>

# Install Ansible
sudo apt update
sudo apt install -y ansible

# Create inventory file
cat > /home/ssm-user/inventory.ini << 'EOF'
[web]
10.0.0.5 ansible_user=ubuntu ansible_ssh_private_key_file=/home/ssm-user/.ssh/id_ed25519

[monitoring]
10.0.0.136 ansible_user=ubuntu ansible_ssh_private_key_file=/home/ssm-user/.ssh/id_ed25519
EOF

# Download SSH key from S3
sudo snap install aws-cli --classic
sudo aws s3 cp s3://devops-bootcamp-terraform-sharil/id_ed25519 /home/ssm-user/.ssh/id_ed25519
sudo chmod 600 /home/ssm-user/.ssh/id_ed25519
sudo chown ssm-user:ssm-user /home/ssm-user/.ssh/id_ed25519
```

### 3. Run Ansible Playbooks

```bash
# Test connectivity
ansible all -i inventory.ini -m ping

# Install Docker on web + monitoring
ansible-playbook -i inventory.ini docker-playbook.yml

# Install node_exporter on web server
ansible-playbook -i inventory.ini playbook-exporter.yml

# Deploy Prometheus + Grafana stack
ansible-playbook -i inventory.ini playbook-monitoring.yml
```

### 4. Build & Push Application

```bash
cd app
docker build -t devops-bootcamp/final-project-sharil:latest .
docker tag devops-bootcamp/final-project-sharil:latest 132656278182.dkr.ecr.ap-southeast-1.amazonaws.com/devops-bootcamp/final-project-sharil:latest
docker push 132656278182.dkr.ecr.ap-southeast-1.amazonaws.com/devops-bootcamp/final-project-sharil:latest
```

### 5. Deploy Container to Web Server

```bash
# From controller (SSM)
ansible-playbook -i inventory.ini app-deploy-playbook.yml
```

---

## 📊 Monitoring

- **Prometheus** scrapes `node_exporter` on web server every 15 seconds
- **Grafana** dashboard: Node Exporter Full (ID: 1860)
- **Metrics collected**: CPU, memory, disk usage, network traffic, uptime

**Access Grafana:** [https://monitoring.myvision.asia](https://monitoring.myvision.asia)

**Prometheus Targets:**
- `prometheus` (localhost:9090) — UP
- `node_exporter` (10.0.0.5:9100) — UP

---

## 🔒 Security Features

- ✅ **No public SSH** — Only AWS SSM access (port 22 not exposed to internet)
- ✅ **IAM least privilege** — ECR PullOnly policy for servers
- ✅ **Cloudflare Tunnel** — Monitoring server not publicly exposed
- ✅ **HTTPS everywhere** — Via Cloudflare SSL
- ✅ **Private subnets** — Controller and monitoring not internet-accessible
- ✅ **Security groups** — Port 9100 only accessible from monitoring server
- ✅ **SSM instance profile** — All servers managed via SSM

---

## 🎯 Bonus Features

- ✅ **Ansible + SSM**: Configuration without port 22 exposure
- ✅ **Cloudflare Tunnel**: Zero-trust monitoring access
- ✅ **Cloudflare Proxy**: Web server behind Cloudflare CDN
- ✅ **IAM Least Privilege**: Minimal permissions per server
- ✅ **Terraform-generated inventory**: Auto-generated Ansible inventory
- ✅ **GitHub Pages**: Documentation with custom domain
- ✅ **Multi-stage Dockerfile**: Optimized production image

---

## 📸 Screenshots

### Web Application
![Web App](docs/screenshots/web-app.png)

### Grafana Dashboard
![Grafana](docs/screenshots/grafana-dashboard.png)

### Prometheus Targets
![Prometheus](docs/screenshots/prometheus-targets.png)

---

## 👤 Author

**Sharil** — DevOps Bootcamp 2026

- GitHub: [@sharil10](https://github.com/sharil10)
- Project: [devops-bootcamp-project](https://github.com/sharil10/devops-bootcamp-project)

---

## 📝 License

This project is part of the DevOps Bootcamp 2026 program by Infratify.