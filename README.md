<div align="center"><a href="https://donate.unrwa.org/int/en/general"><img src="https://raw.githubusercontent.com/Safouene1/support-palestine-banner/master/banner-support.svg" alt="Support Palestine" style="width: 100%;"></a></div>

# 🚀 FastAPI Docker Traefik Starter Template

<p align="center">
    <img src="https://img.shields.io/badge/FastAPI-Async%20Python%203.13-0ba360?style=for-the-badge&colorA=363a4f&colorB=a6da95&logo=fastapi&logoColor=white"/>
    <img src="https://img.shields.io/badge/Dockerized-Easy%20Deploy%20App-2396ed?style=for-the-badge&colorA=363a4f&colorB=89dceb&logo=docker&logoColor=white"/>
    <img src="https://img.shields.io/badge/Traefik-HTTPS%20+%20Load%20Balancing-f5a97f?style=for-the-badge&colorA=363a4f&colorB=f5a97f&logo=traefikmesh&logoColor=white"/>
    <img src="https://img.shields.io/badge/GitHub%20Actions-CI%2FCD%20Ready-8aadf4?style=for-the-badge&colorA=363a4f&colorB=b7bdf8&logo=githubactions&logoColor=white"/>
    <img src="https://img.shields.io/badge/Let's%20Encrypt-Automated%20SSL-e0af68?style=for-the-badge&colorA=363a4f&colorB=e0af68&logo=letsencrypt&logoColor=white"/>
    <img src="https://img.shields.io/badge/Google%20Cloud%20Run-Serverless%20Deploy-4285F4?style=for-the-badge&colorA=363a4f&colorB=8aadf4&logo=googlecloud&logoColor=white"/>
</p>

Production-ready FastAPI template with **two deployment options**: traditional VPS with Traefik or serverless Google
Cloud Run. Choose your path below! 🚀

> [!NOTE]
> This template supports two completely different deployment strategies. Choose the one that best fits your needs and
> infrastructure preferences.

## ✨ Features

* 🐳 **Dockerized FastAPI** with Python 3.13 and `uv` for fast builds
* 🔄 **GitHub Actions CI/CD** with automated testing and deployment
* 🔒 **HTTPS by default** (Let's Encrypt for VPS, Google-managed for Cloud Run)
* 📦 **Multi-registry support** (GHCR + Google Artifact Registry)
* ⚡ **Two deployment paths** - choose what fits your needs

---

## 📁 Project Structure

```
.
├── app/                  # Your FastAPI app
│   └── main.py           # Sample FastAPI "Hello World"
├── docker-compose.yml    # Services: Traefik + App (VPS only)
├── Dockerfile            # Multi-stage build with uv
├── pyproject.toml        # Project + dependency config
├── infra/cloud-run/      # Terraform for GCP Cloud Run
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
├── .env.example          # Sample environment vars
├── .github/              # GitHub Actions workflows
```

---

## 🎯 Choose Your Deployment Path

> [!IMPORTANT]
> You must choose **only one** deployment path. The GitHub Actions workflow is configured to use either VPS or Cloud
> Run, not both simultaneously.

### 🖥️ Option 1: VPS Deployment (Traditional)

**Best for:** Full control, custom domains, existing infrastructure

- ✅ Complete server control
- ✅ Traefik load balancer with Let's Encrypt SSL
- ✅ Docker Compose orchestration
- ✅ SSH-based deployment

**[👉 Go to VPS Setup](#-vps-deployment-path)**

### ☁️ Option 2: Google Cloud Run (Serverless)

**Best for:** Scalability, simplicity, pay-per-use

- ✅ Serverless autoscaling (0 to N instances)
- ✅ Google-managed HTTPS and load balancing
- ✅ Terraform Infrastructure-as-Code
- ✅ No server maintenance

**[👉 Go to Cloud Run Setup](#%EF%B8%8F-cloud-run-deployment-path)**

---

# 🖥️ VPS Deployment Path

## Prerequisites

> [!WARNING]
> Ensure your domain's DNS A record points to your VPS IP address before starting. SSL certificate generation will fail
> without proper DNS configuration.

* Linux VPS (Ubuntu 22.04 recommended)
* Domain name pointed to your VPS IP
* Docker & Docker Compose installed

## Step 1: VPS Server Setup

### Install Docker

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

> [!IMPORTANT]
> Make sure to add Docker to your user group so that you can run it without root access.
> ```bash
> sudo usermod -aG docker $USER
> newgrp docker
> ```

### Create Deployment User

> [!TIP]
> Using a dedicated deployment user improves security by limiting privileges and isolating deployment operations.

```bash
# Create non-root user for deployments
sudo adduser deployer
sudo usermod -aG sudo deployer
sudo usermod -aG docker deployer
```

### Configure SSH Access

```bash
# Generate SSH key pair (on your local machine)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy public key to VPS
ssh-copy-id deployer@your-vps-ip
```

> [!CAUTION]
> Test SSH key authentication before disabling password authentication. Keep a backup terminal session open until you
> confirm key-based login works.

### Harden SSH Security

```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Add these settings:
# PermitRootLogin no
# PasswordAuthentication no

# Restart SSH service
sudo systemctl restart ssh
```

### Setup Firewall

> [!WARNING]
> Configure the firewall carefully. Incorrect settings can lock you out of your server.

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

### Create Let's Encrypt Directory

```bash
sudo mkdir -p /etc/letsencrypt
sudo chown deployer:deployer /etc/letsencrypt
sudo chmod 700 /etc/letsencrypt
```

> [!NOTE]
> This directory will store SSL certificates generated by Let's Encrypt through Traefik.

## Step 2: Configure Your Project

### Clone and Setup

```bash
git clone https://github.com/atick-faisal/fastapi-docker-traefik.git
cd fastapi-docker-traefik
cp .env.example .env
```

### Edit Environment Variables

> [!IMPORTANT]
> Replace these values with your actual domain and email address:

```env
DOMAIN_NAME=yourdomain.com
ACME_EMAIL=you@example.com
```

## Step 3: GitHub Actions Setup

### Required GitHub Secrets

> [!CAUTION]
> Keep these secrets secure. Never commit them to your repository or share them publicly.

| Secret Name   | Description                   |
|---------------|-------------------------------|
| `VPS_HOST`    | Your VPS IP address or domain |
| `VPS_USER`    | VPS username (e.g., deployer) |
| `VPS_SSH_KEY` | Private SSH key content       |

### Enable VPS Deployment

> [!IMPORTANT]
> In `.github/workflows/deploy.yml`, ensure the `deploy-vps` job is **uncommented** and `deploy-cloud-run` is *
*commented out**.

## Step 4: Deploy

> [!TIP]
> Test your Docker setup locally before pushing to production:

```bash
# Test locally first
docker compose up --build
```

```bash
# Push to trigger deployment
git add .
git commit -m "Configure VPS deployment"
git push origin main
```

Your app will be available at `https://yourdomain.com` with automatic HTTPS!

> [!NOTE]
> SSL certificate generation may take a few minutes on the first deployment. Check Traefik logs if you encounter issues.

### VPS Management Commands

```bash
# View logs
docker compose logs -f

# Restart services  
docker compose restart

# Update deployment
git pull origin main
docker compose up -d --build

# Clean up
docker image prune -f
```

---

# ☁️ Cloud Run Deployment Path

## Prerequisites

> [!WARNING]
> Google Cloud Run may incur charges based on usage. Review Google Cloud pricing before proceeding.

* Google Cloud Platform account
* `gcloud` CLI [installed](https://cloud.google.com/sdk/docs/install)
  and [authenticated](https://cloud.google.com/docs/authentication/gcloud)
* Terraform [installed](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* Domain name (optional, Cloud Run provides a URL)

> [!TIP]
> Enable the required APIs in your GCP project:
> ```bash
> gcloud services enable run.googleapis.com artifactregistry.googleapis.com
> ```

## Step 1: Configure Infrastructure

### Edit Terraform Variables

```bash
cp infra/cloud-run/terraform.tfvars.example infra/cloud-run/terraform.tfvars
```

Edit `infra/cloud-run/terraform.tfvars`:

> [!IMPORTANT]
> Replace all placeholder values with your actual project information:

```hcl
project_id         = "your-gcp-project-id"
region             = "me-central1"
github_repo        = "fastapi-docker-traefik"
github_repo_owner  = "your-github-username"
service_account_id = "github-actions-sa"
gar_repo_name      = "fastapi-docker-traefik"
```

### Deploy Infrastructure

> [!CAUTION]
> Review the Terraform plan carefully before applying. This will create billable resources in your GCP project.

```bash
cd infra/cloud-run
terraform init
terraform plan
terraform apply
```

This creates:

- Workload Identity Pool for GitHub Actions
- Service Account with required permissions
- Artifact Registry repository
- IAM bindings

> [!NOTE]
> Terraform will output the values needed for GitHub secrets configuration.

## Step 2: GitHub Actions Setup

### Required GitHub Secrets

> [!IMPORTANT]
> Terraform output will show you the exact values needed. Copy them precisely:

| Secret Name                 | Description                    |
|-----------------------------|--------------------------------|
| `GCP_PROJECT_ID`            | Your Google Cloud project ID   |
| `REGION`                    | GCP region (e.g., us-central1) |
| `GAR_REPOSITORY_NAME`       | Artifact Registry repo name    |
| `WIF_PROVIDER_ID`           | Workload Identity Provider ID  |
| `GCP_SERVICE_ACCOUNT_EMAIL` | Service account email          |

### Enable Cloud Run Deployment

> [!IMPORTANT]
> In `.github/workflows/deploy.yml`, ensure the `deploy-cloud-run` job is **uncommented** and `deploy-vps` is *
*commented out**.

## Step 3: Deploy

```bash
# Push to trigger deployment
git add .
git commit -m "Configure Cloud Run deployment"
git push origin main
```

> [!TIP]
> Your app will be available at the Cloud Run URL shown in the GitHub Actions output! The URL format is typically:
> `https://SERVICE-NAME-HASH-REGION.a.run.app`

### Cloud Run Management

```bash
# View service details
gcloud run services describe fastapi-docker-traefik --region=us-central1

# View logs
gcloud run services logs tail fastapi-docker-traefik --region=us-central1

# Update service manually
gcloud run deploy fastapi-docker-traefik \
  --image=us-central1-docker.pkg.dev/PROJECT_ID/REPO/fastapi-docker-traefik:latest \
  --region=us-central1
```

---

## 🧪 Local Development

### Setup Development Environment

> [!TIP]
> Using `uv` provides significantly faster dependency resolution and installation compared to pip.

```bash
# Install uv (fast Python package manager)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install dependencies
uv sync --all-extras --dev

# Run tests
uv run ruff check
uv run pytest

# Run locally
uv run fastapi dev app/main.py
```

### Docker Development

```bash
# Run with Docker Compose (VPS-like environment)
docker compose up --build

# Run single container
docker build -t fastapi-app .
docker run -p 8080:8080 fastapi-app
```

> [!NOTE]
> The local development server runs on port 8000, while the Docker container runs on port 8080.

---

## 🔧 Customization

### Modify Your FastAPI App

Edit `app/main.py` to build your application. The template includes:

```python
from fastapi import FastAPI

app = FastAPI(title="Your App Name")


@app.get("/")
async def root():
    return {"message": "Hello World"}
```

> [!TIP]
> Add your API routes, middleware, and dependencies to this file. Consider organizing larger applications into multiple
> modules.

### Environment Variables

Both deployment paths support environment variables:

> [!IMPORTANT]
> Never commit sensitive environment variables to your repository. Use GitHub Secrets for sensitive data.

```env
# .env file (VPS) or Cloud Run environment variables
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
SECRET_KEY=your-secret-key
```

### Custom Domains

**VPS**: Configure DNS A record → automatic HTTPS via Let's Encrypt

**Cloud Run**: Use Cloud Run domain mapping for custom domains

> [!NOTE]
> Custom domains on Cloud Run require domain verification and may incur additional charges.

---

## 🚨 Troubleshooting

### VPS Issues

> [!WARNING]
> If SSL certificate generation fails, check that your domain's DNS records are correctly configured and propagated.

```bash
# Check Traefik logs
docker compose logs traefik

# Check SSL certificates
docker compose exec traefik cat /etc/traefik/acme/acme.json

# Verify DNS resolution
dig yourdomain.com
```

> [!TIP]
> Common issues:
> - DNS not propagated (wait 24-48 hours after DNS changes)
> - Firewall blocking ports 80/443
> - Incorrect domain name in configuration

### Cloud Run Issues

```bash
# Check deployment status
gcloud run services list

# View recent logs
gcloud run services logs tail SERVICE_NAME --region=REGION

# Check IAM permissions
gcloud projects get-iam-policy PROJECT_ID
```

> [!CAUTION]
> If deployment fails, check:
> - GitHub Actions logs for detailed error messages
> - Service account permissions in GCP IAM
> - Artifact Registry repository accessibility

---

## 🙌 Acknowledgements

* Inspired by [`dreamsofcode-io/guestbook`](https://github.com/dreamsofcode-io/guestbook)
* Uses [`uv`](https://github.com/astral-sh/uv) for dependency management
* Built by [@atick-faisal](https://github.com/atick-faisal)

<p align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.svg?sanitize=true" />
</p>

<p align="center">
  <a href="https://sites.google.com/view/mchowdhury" target="_blank">Qatar University Machine Learning Group</a>
</p>

<p align="center">
  <a href="https://github.com/atick-faisal/fastapi-docker-traefik/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/atick-faisal/fastapi-docker-traefik?style=for-the-badge&colorA=363a4f&colorB=b7bdf8"/>
  </a>
</p>
