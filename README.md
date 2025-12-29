Readme.md file for assignment 2

# Assignment 2 - Multi-Tier Web Infrastructure

## ��� Project Overview

This project deploys a production-ready multi-tier web infrastructure on AWS using Terraform modules and Nginx as a reverse proxy/load balancer with advanced configurations.

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         INTERNET                                │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            │ HTTPS (443) / HTTP (80)
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                        AWS CLOUD                                │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    VPC (10.0.0.0/16)                      │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │              Subnet (10.0.10.0/24)                  │  │  │
│  │  │                                                     │  │  │
│  │  │         ┌────────────────────┐                      │  │  │
│  │  │         │   Nginx Server     │                      │  │  │
│  │  │         │  ┌──────────────┐  │                      │  │  │
│  │  │         │  │ SSL/TLS     │  │                      │  │  │
│  │  │         │  │ Caching     │  │                      │  │  │
│  │  │         │  │ Load Balance│  │                      │  │  │
│  │  │         │  └──────────────┘  │                      │  │  │
│  │  │         └─────────┬──────────┘                      │  │  │
│  │  │                   │                                 │  │  │
│  │  │     ┌─────────────┼─────────────┐                   │  │  │
│  │  │     │             │             │                   │  │  │
│  │  │     ▼             ▼             ▼                   │  │  │
│  │  │  ┌─────┐       ┌─────┐       ┌─────┐                │  │  │
│  │  │  │Web-1│       │Web-2│       │Web-3│                │  │  │
│  │  │  │ ���  │       │ ���  │       │ ���  │                │  │  │
│  │  │  └─────┘       └─────┘       └─────┘                │  │  │
│  │  │  Primary       Primary       Backup                 │  │  │
│  │  │                                                     │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Components Description

| Component | Description | Port |
|-----------|-------------|------|
| **Nginx Server** | Reverse proxy & load balancer with SSL/TLS termination, caching | 80, 443 |
| **Web-1** | Primary Apache backend server | 80 |
| **Web-2** | Primary Apache backend server | 80 |
| **Web-3** | Backup Apache server (failover only) | 80 |

---

## ��� Prerequisites

### Required Tools

| Tool | Version | Installation Command |
|------|---------|---------------------|
| Terraform | >= 1.0 | `winget install Hashicorp.Terraform` |
| AWS CLI | >= 2.0 | `winget install Amazon. AWSCLI` |
| Git | Latest | `winget install Git. Git` |
| GitHub CLI | Latest | `winget install GitHub.cli` |

### AWS Credentials Setup

```bash
# Configure AWS CLI with your credentials
aws configure
```

When prompted, enter: 
- AWS Access Key ID:  `<your-access-key>`
- AWS Secret Access Key: `<your-secret-key>`
- Default region: `me-central-1`
- Default output format: `json`

### SSH Key Setup

```bash
# Generate SSH key pair
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""

# Set proper permissions
chmod 700 ~/.ssh
chmod 600 ~/. ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

---

## ��� Deployment Instructions

### Step 1: Clone the Repository

```bash
git clone https://github.com/aimen899/Assignment2.git
cd Assignment2
```

### Step 2: Configure Variables

Edit `terraform.tfvars` with your values:

```hcl
vpc_cidr_block    = "10.0.0.0/16"
subnet_cidr_block = "10.0.10.0/24"
availability_zone = "me-central-1a"
env_prefix        = "prod"
instance_type     = "t3.micro"
public_key        = "~/.ssh/id_ed25519.pub"
private_key       = "~/.ssh/id_ed25519"
aws_region        = "me-central-1"
```

### Step 3: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Preview changes
terraform plan

# Apply configuration
terraform apply -auto-approve
```

### Step 4: Get Output Values

```bash
# Display all outputs
terraform output

# Export to JSON file
terraform output -json > outputs.json
```

---

## ⚙️ Post-Deployment Configuration

### Update Nginx Backend IPs

After deployment, update Nginx with actual backend server private IPs:

**Step 1: Get Backend IPs**

```bash
terraform output backend_servers_info
```

**Step 2: SSH into Nginx Server**

```bash
# Get Nginx public IP
NGINX_IP=$(terraform output -raw nginx_public_ip)

# SSH into Nginx
ssh -i ~/.ssh/id_ed25519 ec2-user@$NGINX_IP
```

**Step 3: Edit Nginx Configuration**

```bash
sudo vim /etc/nginx/nginx.conf
```

**Step 4: Update Upstream Block**

Find and replace the placeholder IPs:

```nginx
upstream backend_servers {
    server <web-1-private-ip>:80;         # Replace with actual IP
    server <web-2-private-ip>:80;         # Replace with actual IP
    server <web-3-private-ip>:80 backup;  # Replace with actual IP
}
```

**Step 5: Test and Restart Nginx**

```bash
# Test configuration syntax
sudo nginx -t

# Restart Nginx service
sudo systemctl restart nginx

# Verify status
sudo systemctl status nginx
```

---

## ��� Nginx Configuration Details

### Feature Summary

| Feature | Configuration | Purpose |
|---------|---------------|---------|
| **SSL/TLS** | Self-signed certificate | Encrypts client-server traffic |
| **Load Balancing** | Round-robin algorithm | Distributes traffic evenly |
| **Backup Server** | `backup` directive on web-3 | Failover when primaries fail |
| **Caching** | `proxy_cache` directive | Reduces backend load |
| **Security Headers** | HSTS, X-Frame-Options, etc. | Protection against attacks |
| **HTTP Redirect** | 301 redirect to HTTPS | Forces secure connections |

### Security Headers Implemented

| Header | Value | Protection |
|--------|-------|------------|
| Strict-Transport-Security | max-age=31536000 | Forces HTTPS |
| X-Frame-Options | SAMEORIGIN | Prevents clickjacking |
| X-Content-Type-Options | nosniff | Prevents MIME sniffing |
| X-XSS-Protection | 1; mode=block | XSS attack protection |

---

## ��� Testing Procedures

### Test 1: Verify Load Balancing

```bash
# Method 1: Using curl (run multiple times)
curl -k https://<nginx-public-ip>

# Method 2: Using browser
# Open https://<nginx-public-ip>
# Refresh page 10+ times
# Observe responses from web-1 and web-2 alternating
```

### Test 2: Verify Caching

```bash
# First request - should show MISS
curl -I -k https://<nginx-public-ip>
# Look for:  X-Cache-Status:  MISS

# Second request - should show HIT
curl -I -k https://<nginx-public-ip>
# Look for: X-Cache-Status: HIT
```

### Test 3: Verify High Availability

```bash
# Step 1: Stop Apache on web-1
ssh -i ~/.ssh/id_ed25519 ec2-user@<web-1-public-ip>
sudo systemctl stop httpd
exit

# Step 2:  Verify traffic goes to web-2 only
# Refresh browser - should only show web-2

# Step 3: Stop Apache on web-2
ssh -i ~/.ssh/id_ed25519 ec2-user@<web-2-public-ip>
sudo systemctl stop httpd
exit

# Step 4: Verify backup (web-3) activates
# Refresh browser - should now show web-3

# Step 5: Restore services
ssh -i ~/.ssh/id_ed25519 ec2-user@<web-1-public-ip>
sudo systemctl start httpd
exit

ssh -i ~/.ssh/id_ed25519 ec2-user@<web-2-public-ip>
sudo systemctl start httpd
exit
```

### Test 4: Verify SSL/TLS and Security Headers

```bash
# Check SSL certificate
openssl s_client -connect <nginx-public-ip>:443 -showcerts

# Check security headers
curl -I -k https://<nginx-public-ip>

# Test HTTP to HTTPS redirect
curl -I http://<nginx-public-ip>
# Should show:  HTTP/1.1 301 Moved Permanently
```

---

## ���️ Architecture Details

### Network Topology

| Resource | CIDR/Value | Description |
|----------|------------|-------------|
| VPC | 10.0.0.0/16 | Virtual Private Cloud |
| Subnet | 10.0.10.0/24 | Public subnet |
| Internet Gateway | Attached to VPC | Internet access |
| Route Table | 0.0.0.0/0 → IGW | Default route |

### Security Groups Configuration

**Nginx Security Group (nginx-sg)**

| Direction | Port | Protocol | Source | Description |
|-----------|------|----------|--------|-------------|
| Ingress | 22 | TCP | My IP | SSH access |
| Ingress | 80 | TCP | 0.0.0.0/0 | HTTP access |
| Ingress | 443 | TCP | 0.0.0.0/0 | HTTPS access |
| Egress | All | All | 0.0.0.0/0 | All outbound |

**Backend Security Group (backend-sg)**

| Direction | Port | Protocol | Source | Description |
|-----------|------|----------|--------|-------------|
| Ingress | 22 | TCP | My IP | SSH access |
| Ingress | 80 | TCP | nginx-sg | HTTP from Nginx only |
| Egress | All | All | 0.0.0.0/0 | All outbound |

### Load Balancing Strategy

| Aspect | Configuration |
|--------|---------------|
| Algorithm | Round-robin (default) |
| Primary Servers | web-1, web-2 (active-active) |
| Backup Server | web-3 (standby mode) |
| Failover | Automatic on primary failure |
| Health Check | Passive (based on failed requests) |

---

## ��� Troubleshooting Guide

### Common Issues and Solutions

**Issue 1: Terraform init fails**

```bash
# Solution: Upgrade and reinitialize
terraform init -upgrade
```

**Issue 2: Cannot SSH into instances**

```bash
# Check your current public IP
curl icanhazip.com

# Verify key permissions
chmod 600 ~/.ssh/id_ed25519

# Test SSH connection with verbose mode
ssh -v -i ~/.ssh/id_ed25519 ec2-user@<instance-ip>
```

**Issue 3: Nginx shows 502 Bad Gateway**

```bash
# SSH into Nginx server
ssh -i ~/. ssh/id_ed25519 ec2-user@<nginx-public-ip>

# Check if backend IPs are configured correctly
sudo cat /etc/nginx/nginx.conf | grep -A5 "upstream"

# Test connection to backend
curl http://<backend-private-ip>

# Check Nginx error logs
sudo tail -50 /var/log/nginx/error. log
```

**Issue 4: Backend servers not responding**

```bash
# SSH into backend server
ssh -i ~/.ssh/id_ed25519 ec2-user@<backend-public-ip>

# Check Apache status
sudo systemctl status httpd

# Start Apache if stopped
sudo systemctl start httpd

# Check Apache error logs
sudo tail -50 /var/log/httpd/error_log
```

**Issue 5: SSL certificate warnings**

This is expected behavior with self-signed certificates.  For production environments, use: 
- AWS Certificate Manager (ACM)
- Let's Encrypt (free SSL)

### Log File Locations

| Service | Log File Path |
|---------|---------------|
| Nginx Access Log | `/var/log/nginx/access.log` |
| Nginx Error Log | `/var/log/nginx/error.log` |
| Apache Access Log | `/var/log/httpd/access_log` |
| Apache Error Log | `/var/log/httpd/error_log` |
| System Log | `/var/log/messages` |

### Useful Debug Commands

```bash
# Check Nginx configuration syntax
sudo nginx -t

# View Nginx status
sudo systemctl status nginx

# View real-time Nginx access logs
sudo tail -f /var/log/nginx/access. log

# View real-time Nginx error logs
sudo tail -f /var/log/nginx/error. log

# Check listening ports
sudo netstat -tlnp

# Check Nginx worker processes
ps aux | grep nginx

# Test backend connectivity from Nginx
curl -I http://<backend-private-ip>: 80
```

---

## ��� Project Structure

```
Assignment2/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions with validation
├── outputs.tf                 # Output definitions
├── locals.tf                  # Local values and data sources
├── terraform.tfvars           # Variable values (gitignored)
├── .gitignore                 # Git ignore patterns
├── README.md                  # Project documentation
├── modules/
│   ├── networking/            # Networking module
│   │   ├── main.tf            # VPC, Subnet, IGW, Route Table
│   │   ├── variables.tf       # Module variables
│   │   └── outputs. tf         # Module outputs
│   ├── security/              # Security module
│   │   ├── main.tf            # Security Groups
│   │   ├── variables. tf       # Module variables
│   │   └── outputs.tf         # Module outputs
│   └── webserver/             # Webserver module
│       ├── main.tf            # EC2 Instance, Key Pair
│       ├── variables.tf       # Module variables
│       └── outputs.tf         # Module outputs
└── scripts/
    ├── nginx-setup.sh         # Nginx installation and config
    └── apache-setup.sh        # Apache installation and config
```

---

## ��� Cleanup Instructions

To destroy all AWS resources and avoid charges:

```bash
# Destroy all resources
terraform destroy

# When prompted, type 'yes' to confirm

# Verify destruction
terraform state list
# Should return empty

# Verify in AWS Console
# EC2 > Instances - No running instances
# VPC > Your VPCs - No Assignment-2 VPC
```

---

## ��� Resource Summary

| Resource Type | Count | Names |
|---------------|-------|-------|
| VPC | 1 | prod-vpc |
| Subnet | 1 | prod-subnet |
| Internet Gateway | 1 | prod-igw |
| Route Table | 1 | prod-rtb |
| Security Groups | 2 | prod-nginx-sg, prod-backend-sg |
| EC2 Instances | 4 | nginx-proxy, web-1, web-2, web-3 |
| Key Pairs | 4 | prod-key-nginx, prod-key-1, prod-key-2, prod-key-3 |

---

## ��� Author Information

| Field | Value |
|-------|-------|
| **Student Name** | Aimen Hafeez |
| **Student ID** | 2023-BSE-002 |
| **Course** | Cloud Computing |
| **Assignment** | 2 - Multi-Tier Web Infrastructure |
| **Submission Date** | 30th Dec, 2025 |

---
