#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root or with sudo" >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  apt-get update
  apt-get install -y curl ca-certificates gnupg lsb-release
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

set -a
# shellcheck disable=SC1091
source .env
set +a

if command -v ufw >/dev/null 2>&1; then
  ufw allow "${HTTP_PORT:-30385}"/tcp >/dev/null 2>&1 || true
  ufw allow "${HTTPS_PORT:-30386}"/tcp >/dev/null 2>&1 || true
  ufw allow 8080/tcp >/dev/null 2>&1 || true
fi

docker compose down --remove-orphans >/dev/null 2>&1 || true
docker compose up -d --build

PUBLIC_IP="${PUBLIC_IP:-}"
if [[ -z "$PUBLIC_IP" ]]; then
  for candidate in \
    "$(curl -fsSL --max-time 3 https://api.ipify.org 2>/dev/null || true)" \
    "$(curl -fsSL --max-time 3 https://ifconfig.me 2>/dev/null || true)" \
    "$(curl -fsSL --max-time 3 https://icanhazip.com 2>/dev/null || true)"; do
    if [[ -n "$candidate" && "$candidate" != "127.0.0.1" ]]; then
      PUBLIC_IP="$candidate"
      break
    fi
  done
fi

if [[ -z "$PUBLIC_IP" ]]; then
  PUBLIC_IP="$(hostname -I | awk '{for (i=1;i<=NF;i++) if ($i !~ /^(127\.|10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|192\.168\.)/) {print $i; exit}}')"
fi

if [[ -z "$PUBLIC_IP" ]]; then
  PUBLIC_IP="$(hostname -I | awk '{print $1}')"
fi

HTTP_PORT="${HTTP_PORT:-30385}"
HTTPS_PORT="${HTTPS_PORT:-30386}"

echo "Priton deployed."
echo "Admin UI: http://${PUBLIC_IP}:${HTTP_PORT}"
echo "API: http://${PUBLIC_IP}:8080"
echo "HTTPS UI: https://${PUBLIC_IP}:${HTTPS_PORT}"
echo "If the service is not reachable, ensure the firewall allows TCP ${HTTP_PORT}, ${HTTPS_PORT}, and 8080."
