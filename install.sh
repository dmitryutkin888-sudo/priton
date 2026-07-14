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

docker compose up -d --build

PUBLIC_IP="$(hostname -I | awk '{print $1}')"

echo "Priton Core installed"
echo "API: http://${PUBLIC_IP}:30385/health"
echo "GUI: http://${PUBLIC_IP}:30385/"
echo "Admin login: admin@priton.dev"
echo "Admin password: changeme"
