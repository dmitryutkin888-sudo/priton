#!/usr/bin/env bash
set -euo pipefail

echo "Checking 30385"
ss -ltnp | grep 30385 || true

echo "Checking local health"
curl -fsS http://127.0.0.1:30385/health || true
