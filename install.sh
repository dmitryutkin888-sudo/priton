#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root or with sudo" >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

if ! command -v docker >/dev/null 2>&1; then
  echo "Installing Docker..."
  apt-get update
  apt-get install -y ca-certificates curl gnupg lsb-release
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  systemctl enable docker --now
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "Docker Compose plugin is not available" >&2
  exit 1
fi

if [[ ! -f .env ]]; then
  cat > .env <<'EOF'
JWT_SECRET=dev-secret
DB_PASS=dev-pass
API_KEY=dev-api-key
TG_BOT_TOKEN=dev-token
EOF
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is not running. Starting it..."
  systemctl start docker || true
fi

if command -v ufw >/dev/null 2>&1; then
  ufw allow 22/tcp >/dev/null 2>&1 || true
  ufw allow 30385/tcp >/dev/null 2>&1 || true
  ufw allow 30386/tcp >/dev/null 2>&1 || true
  ufw --force enable >/dev/null 2>&1 || true
fi

chmod +x scripts/generate-cert.sh >/dev/null 2>&1 || true
./scripts/generate-cert.sh >/dev/null 2>&1 || true

docker compose down --remove-orphans >/dev/null 2>&1 || true
docker compose up -d --build --force-recreate

PUBLIC_IP=""
if command -v curl >/dev/null 2>&1; then
  PUBLIC_IP="$(curl -4fsS https://api.ipify.org 2>/dev/null || true)"
fi

if [[ -z "$PUBLIC_IP" ]]; then
  for candidate in $(hostname -I 2>/dev/null); do
    case "$candidate" in
      10.*|172.16.*|172.17.*|172.18.*|172.19.*|172.20.*|172.21.*|172.22.*|172.23.*|172.24.*|172.25.*|172.26.*|172.27.*|172.28.*|172.29.*|172.30.*|172.31.*|192.168.*) ;;
      *) PUBLIC_IP="$candidate"; break ;;
    esac
  done
fi

if [[ -z "$PUBLIC_IP" ]]; then
  PUBLIC_IP="$(hostname -I | awk '{print $1}')"
fi

echo "Priton Core installed"
echo "API: http://${PUBLIC_IP}:80/health"
echo "GUI: http://${PUBLIC_IP}:80/"
echo "Admin login: admin@priton.dev"
echo "Admin password: changeme"
echo "If your provider blocks the port, run: sudo ufw allow 30385/tcp"
echo "If the port still does not respond, open it in your cloud firewall/security group too."
