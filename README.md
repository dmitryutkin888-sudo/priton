# Priton

Self-hosted VPN / proxy platform scaffold for Ubuntu VPS deployment.

## What is included
- Go backend API with admin and Android-style client endpoints
- Simple embedded web UI
- Python Telegram bot stub
- Docker Compose services for API, PostgreSQL, Redis, Caddy, and bot
- Ubuntu install script for Docker and Compose

## Quick start on Ubuntu
1. Copy the repo to your VPS.
2. Run:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```
3. Open the admin UI at http://<server-ip>:30385/ or https://<server-ip>:30386/ after Caddy is configured.
