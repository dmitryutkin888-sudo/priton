# Priton Core

Priton Core — это self-hosted VPN/Proxy платформа с веб-админкой, REST API, Telegram Bot и контейнерной архитектурой.

## Что уже реализовано
- Go backend API с базовыми маршрутами
- Минимальный GUI (статический веб-интерфейс)
- Docker Compose шаблон для запуска API
- Установочный скрипт `install.sh`
- Базовая схема миграции для пользователей

## Требования
- Ubuntu 22.04/24.04 или Debian 12
- Docker 24+
- Docker Compose v2
- Git
- curl / wget

## Быстрая установка на сервере

```bash
sudo apt update && sudo apt install -y git curl
curl -fsSL https://get.docker.com | sh
sudo apt install -y docker-compose-plugin
```

```bash
git clone https://github.com/<your-username>/priton-core.git
cd priton-core
chmod +x install.sh
sudo ./install.sh
```

## После установки
- API: http://<server-ip>:8080/health
- GUI: http://<server-ip>:8080/
- Admin login: admin@priton.dev
- Admin password: changeme

## Структура проекта
```text
priton-core/
├── backend/
├── web/
├── migrations/
├── docker-compose.yml
├── install.sh
└── README.md
```

## Дальнейшие шаги
- подключить PostgreSQL/Redis
- добавить JWT и реальную авторизацию
- внедрить React GUI
- развернуть протоколы VPN и Telegram bot
