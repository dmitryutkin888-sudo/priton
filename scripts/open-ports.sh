#!/usr/bin/env bash
set -euo pipefail

if command -v ufw >/dev/null 2>&1; then
  ufw allow 22/tcp >/dev/null 2>&1 || true
  ufw allow 30385/tcp >/dev/null 2>&1 || true
  ufw allow 30386/tcp >/dev/null 2>&1 || true
  ufw --force enable >/dev/null 2>&1 || true
fi

echo "Ports opened: 22, 30385, 30386"
