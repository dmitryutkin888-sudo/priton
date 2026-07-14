#!/usr/bin/env bash
set -euo pipefail

mkdir -p certs
openssl req -x509 -nodes -newkey rsa:2048 \
  -keyout certs/server.key \
  -out certs/server.crt \
  -days 365 \
  -subj "/CN=localhost" >/dev/null 2>&1

echo "Certificate generated"
