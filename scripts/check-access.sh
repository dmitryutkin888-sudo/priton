#!/usr/bin/env bash
set -euo pipefail

PUBLIC_IP=""
for candidate in $(hostname -I 2>/dev/null); do
  case "$candidate" in
    10.*|172.16.*|172.17.*|172.18.*|172.19.*|172.20.*|172.21.*|172.22.*|172.23.*|172.24.*|172.25.*|172.26.*|172.27.*|172.28.*|172.29.*|172.30.*|172.31.*|192.168.*) ;;
    *) PUBLIC_IP="$candidate"; break ;;
  esac
done

if [[ -z "$PUBLIC_IP" ]]; then
  PUBLIC_IP="$(hostname -I | awk '{print $1}')"
fi

echo "Checking http://$PUBLIC_IP:30385/health"
curl -fsS "http://$PUBLIC_IP:30385/health" || true
