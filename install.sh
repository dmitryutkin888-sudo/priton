#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root or with sudo" >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  apt-get update
  apt-get install -y ca-certificates curl gnupg lsb-release
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

if ! docker compose version >/dev/null 2>&1; then
  apt-get install -y docker-compose-plugin
fi

if [ ! -f .env ]; then
  cat > .env <<'EOF'
JWT_SECRET=change-me
DB_PASS=priton-pass
API_KEY=change-me
TG_BOT_TOKEN=change-me
HTTP_PORT=30385
HTTPS_PORT=30386
EOF
fi

docker compose down --remove-orphans >/dev/null 2>&1 || true
docker compose up -d --build

echo "Priton deployed."
echo "Admin UI: http://$(hostname -I | awk '{print $1}'):30385"
echo "API: http://$(hostname -I | awk '{print $1}'):8080"
