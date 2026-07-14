#!/usr/bin/env bash
set -euo pipefail

if command -v iptables >/dev/null 2>&1; then
  iptables -I INPUT -p tcp --dport 80 -j ACCEPT >/dev/null 2>&1 || true
  iptables -I INPUT -p tcp --dport 443 -j ACCEPT >/dev/null 2>&1 || true
fi

echo "HTTP/HTTPS ports enabled"
