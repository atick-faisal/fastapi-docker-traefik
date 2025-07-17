# 🚀 FastAPI Docker Traefik Starter Template

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