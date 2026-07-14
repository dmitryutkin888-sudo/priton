#!/usr/bin/env bash
set -euo pipefail

echo "Checking Docker containers..."
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

echo "Checking API health..."
curl -fsS http://127.0.0.1:8080/health || true

echo "Checking Caddy on 30385..."
curl -I -s http://127.0.0.1:30385/ | head -n 5 || true

echo "Checking Caddy on 30386..."
curl -k -I -s https://127.0.0.1:30386/ | head -n 5 || true
