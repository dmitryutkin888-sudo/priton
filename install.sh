#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root or with sudo" >&2
  exit 1
fi

cat > .env <<'EOF'
JWT_SECRET=dev-secret
DB_PASS=dev-pass
API_KEY=dev-api-key
TG_BOT_TOKEN=dev-token
EOF

docker compose up -d --build

echo "Priton Core installed"
echo "API: http://127.0.0.1:8080/health"
echo "Admin login: admin@priton.dev"
echo "Admin password: changeme"
