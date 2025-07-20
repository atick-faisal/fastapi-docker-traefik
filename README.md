<div align="center"><a href="https://donate.unrwa.org/int/en/general"><img src="https://raw.githubusercontent.com/Safouene1/support-palestine-banner/master/banner-support.svg" alt="Support Palestine" style="width: 100%;"></a></div>

# 🚀 FastAPI Docker Traefik Starter Template

<p align="center">
    <img src="https://img.shields.io/badge/FastAPI-Async%20Python%203.13-0ba360?style=for-the-badge&colorA=363a4f&colorB=a6da95&logo=fastapi&logoColor=white"/>
    <img src="https://img.shields.io/badge/Dockerized-Easy%20Deploy%20App-2396ed?style=for-the-badge&colorA=363a4f&colorB=89dceb&logo=docker&logoColor=white"/>
    <img src="https://img.shields.io/badge/Traefik-HTTPS%20+%20Load%20Balancing-f5a97f?style=for-the-badge&colorA=363a4f&colorB=f5a97f&logo=traefikmesh&logoColor=white"/>
    <img src="https://img.shields.io/badge/GitHub%20Actions-CI%2FCD%20Ready-8aadf4?style=for-the-badge&colorA=363a4f&colorB=b7bdf8&logo=githubactions&logoColor=white"/>
    <img src="https://img.shields.io/badge/Let's%20Encrypt-Automated%20SSL-e0af68?style=for-the-badge&colorA=363a4f&colorB=e0af68&logo=letsencrypt&logoColor=white"/>
</p>

<img width="960" height="540" alt="FasAPI-Docker-Traefik" src="https://github.com/user-attachments/assets/24441e0c-7c39-4b5f-94b2-0d0a30e6be60" />

This is your all-in-one 🔥 production-ready template for deploying a FastAPI application on a VPS
using Docker 🐳, Docker Compose, Traefik 🌐, and GitHub Actions CI/CD 💥.

**Features:**

* ✅ Load balancing with Traefik
* ✅ HTTPS with Let's Encrypt
* ✅ Dockerized FastAPI app with Python 3.13
* ✅ GitHub Actions workflow for CI/CD
* ✅ Easy `.env` config for your domain + SSL
* ✅ Multi-stage Docker build using `uv` for fast builds
* ✅ Auto-deploy to your VPS via SSH

---

## 📁 Project Structure

```
.
├── app/                  # Your FastAPI app
│   └── main.py           # Sample FastAPI "Hello World"
├── docker-compose.yml    # Services: Traefik + App
├── Dockerfile            # Multi-stage build with uv
├── pyproject.toml        # Project + dependency config
├── .env.example          # Sample environment vars
├── .github/              # GitHub Actions + config
```

---

Here’s the expanded version of your `README.md` with an improved VPS setup section (including SSH key creation and hardening), and an updated CI/CD section that clearly explains how to integrate your SSH key for deployments.

---

## 🧑‍💻 Getting Started

### 1. 🌐 Set Up Your VPS

Before deploying, you'll need:

* A Linux VPS (e.g., Ubuntu 22.04) 🐧
* A domain name pointed to your VPS IP (use an A record in your DNS provider)
* Docker & Docker Compose installed ([Install Docker](https://docs.docker.com/engine/install/ubuntu/))

#### 🗝️ Set Up SSH Access with Key Pair

If you haven’t already created an SSH key:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Just hit Enter to accept defaults. This will create:

* `~/.ssh/id_ed25519` (private key — keep safe!)
* `~/.ssh/id_ed25519.pub` (public key — to share)

Now, connect to your VPS (as root or user) and add your public key:

```bash
# On your local machine
ssh root@your-vps-ip

# On the VPS
mkdir -p ~/.ssh
echo "your-public-key-content" >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

Now you can log in without a password:

```bash
ssh root@your-vps-ip
```

✅ **Test this in a new terminal before moving on!**

---

#### 👤 Create a Non-Root User for Deployment

```bash
adduser deployer
usermod -aG sudo deployer
```

Then copy your SSH key to the new user:

```bash
mkdir -p /home/deployer/.ssh
cp /root/.ssh/authorized_keys /home/deployer/.ssh/
chown -R deployer:deployer /home/deployer/.ssh
chmod 700 /home/deployer/.ssh
chmod 600 /home/deployer/.ssh/authorized_keys
```

✅ Now try logging in with:

```bash
ssh deployer@your-vps-ip
```

---

#### 🔐 Harden SSH Access

Edit the SSH config:

```bash
sudo nano /etc/ssh/sshd_config
```

Update or add the following lines:

```conf
PermitRootLogin no
PasswordAuthentication no
```

Also, edit the `/etc/ssh/sshd_config.d/50-cloud-init.conf` file and update its content:
```conf
PasswordAuthentication no
```

Then restart the SSH service:

```bash
sudo systemctl restart ssh
```

> [!NOTE]
> From now on, **only SSH key-based login** is allowed, and **root is disabled** from remote login.

---

#### 🔥 Final VPS Setup Steps

Install Docker using the steps [here](https://docs.docker.com/engine/install/ubuntu/).

> [!IMPORTANT]
> Make sure to add Docker to your user group so that you can run it without the root access.
> ```bash
> sudo usermod -aG docker $USER

Enable firewall (UFW):

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH
sudo ufw enable
```

> [!CAUTION]
> Triple check if the ufw rules have been setup correctly or not. If you set up incorrectly, you may not be able to login to your VPS over ssh.

Create Let's Encrypt directory for Traefik:

```bash
sudo mkdir -p /etc/letsencrypt
sudo chown $USER:$USER /etc/letsencrypt
sudo chmod 700 /etc/letsencrypt
```

---

### 2. 📦 Clone This Template

```bash
git clone https://github.com/atick-faisal/fastapi-docker-traefik.git
cd fastapi-docker-traefik
cp .env.example .env
```

Edit `.env`:

```env
DOMAIN_NAME=yourdomain.com
ACME_EMAIL=you@example.com
```

> [!WARNING]
> The `.env` is listed in the .gitignore as it should be. Never push this file to GitHub. 

---

## 🤖 GitHub CI/CD Explained

This repo comes with a fully integrated GitHub Actions workflow to automate the entire deployment process.

### 🛠 How it works:

1. Push to `main` branch triggers GitHub Actions.
2. Code is tested and linted with [`ruff`](https://github.com/astral-sh/ruff) and [`pytest`](https://docs.pytest.org/en/stable/).
3. Docker image is built and pushed to GitHub Container Registry (GHCR).
4. GitHub SSHes into your VPS using the SSH key you provide as a secret.
5. On the VPS, it pulls the new image and restarts the app.

---

### 🔐 Configure GitHub Secrets

To enable the CI/CD workflow, go to your repository on GitHub → ⚙️ **Settings** → **Secrets and variables** → **Actions** → **New repository secret**.

| Secret Name   | Description                                                  |
| ------------- | ------------------------------------------------------------ |
| `VPS_HOST`    | Your VPS public IP or domain                                 |
| `VPS_USER`    | The non-root username (e.g., `deployer`)                     |
| `VPS_SSH_KEY` | Your **private** SSH key content (e.g., `~/.ssh/id_ed25519`) |

Paste the entire contents of your private key into `VPS_SSH_KEY`. GitHub will use this to SSH into your server for deployment.

> [!Important]
> Keep this private key secure! Never commit it to your repo.

---

Let me know if you'd like to include:

* GitHub Actions badge at the top of the README
* A visual flowchart of the CI/CD process
* SSH key revocation and rotation tips

Would you like me to regenerate the full `README.md` with all these changes baked in?


## 🧑‍💻 Getting Started

### 1. 🌐 Set Up Your VPS

Before deploying, you'll need:

* A Linux VPS (e.g., Ubuntu 22.04) 🐧
* A domain name pointed to your VPS IP (use A record in DNS)
* Docker & Docker Compose [installed](https://docs.docker.com/engine/install/ubuntu/).

```bash
# Add Docker to user group for non-root access
sudo usermod -aG docker $USER
```

Enable firewall for safety 🔐:

```bash
sudo ufw default deny incoming # Deny all incoming traffic
sudo ufw default allow outgoing # Allow all outgoing traffic
sudo ufw allow OpenSSH # Allow SSH
sudo ufw enable # Enable the firewall
```

Create letsencrypt directory for Traefik:

```bash
sudo mkdir -p /etc/letsencrypt
sudo chown $USER:$USER /etc/letsencrypt
sudo chmod 700 /etc/letsencrypt
```

---

### 2. 📦 Clone This Template

On your VPS:

```bash
git clone https://github.com/atick-faisal/fastapi-docker-traefik.git
cd fastapi-docker-traefik
cp .env.example .env
```

Edit `.env` with your domain and email for Let's Encrypt:

```env
DOMAIN_NAME=yourdomain.com
ACME_EMAIL=you@example.com
```

---

### 3. 🔐 Optional: Add Your SSH Key to GitHub

To enable CI/CD, add your VPS SSH private key as a GitHub secret:

| Name          | Value                     |
|---------------|---------------------------|
| `VPS_HOST`    | `your.vps.ip.address`     |
| `VPS_USER`    | `your-vps-username`       |
| `VPS_SSH_KEY` | *Your private SSH key* 🔑 |

---

## 🐳 Running Locally (for testing)

```bash
docker compose up --build
```

Then visit [http://localhost](http://localhost) — Traefik will redirect you to HTTPS and serve your
app.

---

## 🚀 Deploy to Production

Push your changes to the `main` branch of your GitHub repo.

```bash
git add .
git commit -m "Initial commit"
git push origin main
```

GitHub Actions will:

1. 🧪 Lint your code using `ruff`
2. 🐳 Build & push the Docker image to GHCR
3. 📡 SSH into your VPS and deploy the latest image

---

## 🌍 Domain + HTTPS via Traefik

Traefik takes care of all the networking magic:

* Listens on ports 80/443
* Automatically gets TLS certs from Let's Encrypt
* Routes traffic to the FastAPI app via labels in `docker-compose.yml`
* Load balances across 3 replicas of the app 🚦

You get:

* ✅ HTTPS by default
* ✅ Zero downtime on redeploys
* ✅ Easy observability with Traefik dashboard (disabled by default in prod)

---

## 🛠 How It Works

* **FastAPI App** runs on port `8080` and returns `{"message": "Hello World"}` at `/`
* **Traefik** reverse proxy forwards traffic to the app
* **Multi-stage Docker build**:

    * `uv` compiles + installs dependencies lightning fast ⚡
    * Final image is tiny and production-optimized
* **CI/CD** with GitHub Actions:

    * Lint → Build → Push → Deploy

---

## 🧪 Dev & Testing

Install [uv](https://github.com/astral-sh/uv) locally and run:

```bash
uv sync --all-extras --dev
uv run ruff check
```

---

## 🧰 Useful Commands

Rebuild containers:

```bash
docker compose up -d --build
```

Check logs:

```bash
docker compose logs -f
```

Access Traefik dashboard (optional, for dev only):

```yaml
# Enable this port in docker-compose.yml:
# - "8080:8080"
```

Then visit: [http://yourdomain.com:8080/dashboard](http://yourdomain.com:8080/dashboard)

---

## 🧼 Clean Up Old Docker Images

CI/CD auto-prunes old images with:

```bash
docker image prune -f
```

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
