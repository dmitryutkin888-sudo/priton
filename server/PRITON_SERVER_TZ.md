# ТЕХНИЧЕСКОЕ ЗАДАНИЕ
## Priton Core — Серверная платформа VPN/Proxy
**Версия документа:** 1.0  
**Дата:** 2026-07-14  
**Целевая аудитория:** AI-агент (GitHub Copilot) + DevOps  
**Язык реализации:** Go (backend), TypeScript/React (GUI), Python (Telegram Bot)  
**Контейнеризация:** Docker + Docker Compose  

---

## 1. Общие положения
Priton Core — это self-hosted VPN-концентратор с веб-админкой, поддержкой множественных протоколов обфускации, master-slave кластеризацией и нативным API для Android-клиента. Ключевая философия: **«одна команда — работающий сервис»** и **«5 кликов до любой информации»** в GUI.

---

## 2. Технологический стек
| Компонент | Технология | Назначение |
|-----------|-----------|------------|
| Backend API | Go 1.22+ (Gin/Echo) | REST API, управление, агрегация |
| GUI Admin | React 18 + Tailwind | Веб-панель (встроена в бинарник, `embed`) |
| База данных | PostgreSQL 16 | Пользователи, подписки, сервера, логи |
| Кэш / Очереди | Redis 7 | Сессии, rate-limit, кэш статусов |
| Reverse Proxy | Caddy 2 | TLS auto, L7 routing, API/WebSocket |
| VPN-ядра | Xray-core, sing-box, amneziawg-go, mtproto-proxy | Протоколы |
| Мониторинг | Grafana + Loki + Prometheus | Логи и метрики (опционально, в compose) |
| Контейнеры | Docker + Compose | Полная изоляция протоколов |

---

## 3. Установка и саморазвёртывание (One-Line Deploy)
Требуется скрипт `install.sh`, который:
1. Проверяет root/sudo.
2. Устанавливает Docker и Docker Compose (если нет).
3. Генерирует `.env` с секретами (`JWT_SECRET`, `DB_PASS`, `API_KEY`, `TG_BOT_TOKEN`).
4. Поднимает `docker-compose up -d`.
5. Выполняет авто-миграции БД.
6. Выводит в консоль URL админки, дефолтный логин/пароль и путь к `priton-cli`.

**Команда установки:**
```bash
curl -fsSL https://get.priton.dev | bash
# или
wget -qO- https://get.priton.dev | bash
```

**CLI-утилита `priton-cli`** (Go-бинарник внутри контейнера, проброшен наружу):
- `priton-cli status` — статус всех сервисов.
- `priton-cli add-node` — добавить slave-ноду.
- `priton-cli reset-admin` — сбросить доступ к GUI.
- `priton-cli logs` — tail всех логов.

---

## 4. Архитектура системы
```
┌─────────────────────────────────────────────────────────────┐
│                        Priton Core                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │   Web GUI    │  │  REST API    │  │  Telegram Bot    │   │
│  │  (React)     │  │   (Go)       │  │   (Python)       │   │
│  └──────┬───────┘  └──────┬───────┘  └────────┬─────────┘   │
│         │                 │                     │             │
│  ┌──────▼───────────────▼─────────────────────▼─────────┐   │
│  │              API Gateway (Caddy)                       │   │
│  └──────┬────────────────┬──────────────┬────────────────┘   │
│         │                │              │                    │
│  ┌──────▼──────┐  ┌─────▼──────┐ ┌────▼──────┐  ┌────────┐│
│  │  User/Sub   │  │   Node     │ │ Protocol  │  │ Logger ││
│  │  Service    │  │  Manager   │ │  Manager  │  │ Service││
│  └──────┬──────┘  └─────┬──────┘ └─────┬─────┘  └────┬───┘│
│         │               │              │             │      │
│  ┌──────▼──────┐  ┌─────▼──────┐ ┌────▼──────┐  ┌────▼───┐  │
│  │ PostgreSQL  │  │   Redis    │ │ Xray/     │  │ Loki/  │  │
│  │             │  │            │ │ AmneziaWG/│  │Prometh.│  │
│  └─────────────┘  └────────────┘ │ MTProto   │  └────────┘  │
│                                └───────────┘               │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. GUI Admin Panel (Правило 5 кликов)
Веб-интерфейс встроен в Go-бинарник (`embed` static). Доступ по `https://<ip>:8443/admin`.

**Информационная архитектура (5 кликов):**
1. **Dashboard** (клик 1) — виджеты: онлайн юзеров, трафик, статус нод, подписки.
2. **Пользователи** (клик 2) — таблица, поиск, фильтр по подписке.
3. **Карточка пользователя** (клик 3) — QR-коды ключей, срок подписки, кнопка «Продлить».
4. **Выбор протокола** (клик 4) — выпадающий список: AmneziaWG / VLESS / SS / Trojan / MTProto.
5. **Конфиг/Ссылка** (клик 5) — копирование ссылки, скачивание `.conf`, отправка в Telegram.

**Основные экраны GUI:**
- **Dashboard** — графики трафика, health-check всех нод, последние 5 логов.
- **Users** — CRUD, назначение подписок, блокировка, просмотр истории подключений.
- **Nodes** — master/slave топология, добавление ноды (кнопка + ввод IP + SSH-ключ), статус репликации.
- **Protocols** — вкл/выкл протоколов, смена портов, обновление Xray/sing-box.
- **Subscriptions** — планы (Free / Premium / Family), цены, сроки, кастомные правила.
- **Telegram Bot** — настройка токена, привязка к серверу, тест сообщения.
- **Logs** — live tail, фильтр по уровню (INFO/WARN/ERROR), фильтр по ноде/пользователю.
- **Settings** — SMTP, бэкап БД, обновление системы (кнопка «Update Priton»).

---

## 6. Поддерживаемые протоколы (анализ для РФ)

### 6.1 AmneziaWG (Amnezia WireGuard)
- **Суть:** форк WireGuard с изменёнными магическими числами в заголовках, добавлением junk-пакетов и padding. DPI видит не WG, а неизвестный UDP-шум.
- **Реализация:** `amneziawg-go` в Docker-контейнере. Порты: 33000-34000 UDP.
- **Конфиг:** стандартный `.conf` + поля `Jc`, `Jmin`, `Jmax`, `S1`, `S2`, `H1`, `H2`, `H3`, `H4`.
- **GUI:** генерация ключей, QR-код, скачивание.

### 6.2 VLESS + XTLS-Reality (Xray-core) — «протокол для Happ/Hiddify»
- **Суть:** маскировка под реальный TLS-сайт (Reality). SNI-spoofing, fingerprint Chrome/Safari. Практически неотличим от обычного HTTPS.
- **Реализация:** Xray-core (v1.8+), inbound VLESS + Reality + Vision flow.
- **Параметры:** `publicKey`, `privateKey`, `shortId`, `spiderX`, `fingerprint`.
- **GUI:** выбор «маскировочного» домена (по умолчанию `www.microsoft.com`), авто-генерация ключей Reality.

### 6.3 Shadowsocks + v2ray-plugin
- **Суть:** классический SS с WebSocket-обфускацией. Легковесный, fallback для слабых сетей.
- **Реализация:** sing-box / shadowsocks-libev.
- **Параметры:** method `aes-256-gcm`, плагин `v2ray-plugin`, `tls`, `host`.

### 6.4 Trojan-GFW
- **Суть:** маскировка под HTTPS. Если нет правильного ключа — отдаётся реальный сайт (fallback).
- **Реализация:** Xray-core / sing-box.
- **Параметры:** password, `sni`, `alpn`.

### 6.5 Hysteria2 (QUIC)
- **Суть:** основан на QUIC, адаптивный congestion control, обфускация через `obfs`.
- **Реализация:** официальный `hysteria` сервер.
- **Параметры:** `obfs`, `quic.window`, `bandwidth`.
- **Нишевый:** отлично работает на мобильных сетях, где TCP throttle.

### 6.6 TUIC (TCP over UDP in QUIC)
- **Суть:** ещё один QUIC-протокол, минималистичный, нативная поддержка в sing-box.
- **Реализация:** tuic-server (Rust) или sing-box.
- **Нишевый:** хорош для игр и стриминга.

### 6.7 MTProto Proxy (Telegram)
- **Суть:** нативный прокси для Telegram. Не подписочный — работает всегда для всех пользователей.
- **Реализация:** `mtproto-proxy` (C) или Python-реализация.
- **Параметры:** `secret` (hex), порт 443.
- **Особенность:** в GUI отдельный блок «Telegram Proxy» — всегда ON, статус «Running».

### 6.8 Zapret (локальный обход DPI) — интеграция на сервере
- **Суть:** Zapret работает локально на клиенте, но сервер должен быть **совместим** с его техниками (например, не рвать соединение при фрагментации TCP).
- **Требование к серверу:** поддержка TCP-segment offloading, корректная обработка фрагментированных TLS-hello.
- **Интеграция:** в API передавать флаг `zapret_compatible: true` для конфигов, чтобы клиент знал, что сервер не блокирует обфусцированный трафик.

---

## 7. Система пользователей и подписок

### 7.1 Сущности БД
```sql
-- users
id UUID PRIMARY KEY,
email VARCHAR(255) UNIQUE,
phone VARCHAR(20),
tg_id BIGINT,
subscription_plan ENUM('free', 'premium', 'family'),
subscription_expires_at TIMESTAMP,
client_key VARCHAR(64) UNIQUE, -- ключ для Android-приложения
is_active BOOLEAN DEFAULT true,
created_at TIMESTAMP DEFAULT NOW()

-- user_keys
id UUID PRIMARY KEY,
user_id UUID REFERENCES users(id),
protocol VARCHAR(50), -- 'amneziawg', 'vless', 'ss', 'trojan', 'hysteria2', 'tuic'
node_id UUID REFERENCES nodes(id),
config_json JSONB, -- полный конфиг
connection_string TEXT, -- ss://..., vless://...
qr_data TEXT,
created_at TIMESTAMP

-- nodes (master/slave)
id UUID PRIMARY KEY,
role ENUM('master', 'slave') DEFAULT 'slave',
master_node_id UUID REFERENCES nodes(id), -- NULL для master
ip_address INET,
location VARCHAR(100), -- 'Russia', 'Europe', 'Asia'
status ENUM('active', 'offline', 'maintenance') DEFAULT 'active',
load_percent INT DEFAULT 0,
last_heartbeat TIMESTAMP,
ssh_key TEXT, -- для авто-настройки slave
api_token VARCHAR(255) -- slave -> master auth

-- subscriptions
id UUID PRIMARY KEY,
name VARCHAR(100), -- 'Premium Monthly'
price DECIMAL(10,2),
duration_days INT,
max_devices INT,
protocols_allowed JSONB, -- ["all"] или ["amneziawg", "vless"]
features JSONB -- {"tg_bot": true, "auto_switch": true}
```

### 7.2 Выдача подписки через GUI
**Сценарий (5 кликов):**
1. Админ открывает **Users** → кнопка «+ Add User» (клик 1).
2. Вводит email / Telegram username (клик 2 — ввод данных).
3. Выбирает план подписки из выпадающего списка (клик 3).
4. Нажимает «Generate Keys» — система создаёт ключи для всех активных протоколов на всех доступных нодах (клик 4).
5. Открывается карточка с QR-кодами и ссылками → кнопка «Send to Telegram» (клик 5).

---

## 8. Master-Slave кластеризация и балансировка

### 8.1 Топология
- **Master** — единственный. Хранит БД, GUI, API, Telegram Bot. Принимает решения о балансировке.
- **Slave** — VPN-ноды (чистые прокси/протоколы). Получают конфиги от Master через защищённый API.

### 8.2 Добавление Slave через GUI
1. **Nodes** → **Add Node** (клик 1).
2. Ввод IP-адреса, выбор региона (клик 2).
3. Загрузка SSH-публичного ключа (или авто-генерация) (клик 3).
4. Нажатие «Deploy Node» — backend выполняет SSH на slave, ставит Docker, поднимает VPN-контейнеры (клик 4).
5. Статус «Active» в таблице нод (клик 5 — просмотр статуса).

### 8.3 Распределение нагрузки
- Алгоритм: **Round-Robin + Least Connections**.
- Каждые 30 секунд slave отправляет heartbeat на `/api/internal/heartbeat` с метриками: CPU%, RAM%, active_connections, tx/rx bytes.
- Master пересчитывает `load_percent` и выбирает ноду для нового клиента.
- Если нода offline (>90 сек без heartbeat) — исключается из выдачи.
- **API endpoint для клиента:** `GET /api/v1/best-node` — возвращает оптимальную ноду и конфиг.

### 8.4 API между Master и Slave
```http
POST /api/internal/heartbeat
Authorization: Bearer <SLAVE_TOKEN>
Content-Type: application/json

{
  "node_id": "uuid",
  "cpu_percent": 45.2,
  "ram_percent": 60.1,
  "active_connections": 124,
  "tx_bytes": 1098765432,
  "rx_bytes": 987654321,
  "timestamp": "2026-07-14T12:00:00Z"
}

Response 200:
{
  "config_update": true,
  "configs": [...] // новые/обновлённые конфиги пользователей
}
```

```http
POST /api/internal/sync-users
Authorization: Bearer <SLAVE_TOKEN>
Body: { "users": [ ... ] }

Response 200: { "applied": true }
```

---

## 9. Telegram Bot

### 9.1 Назначение
- Получение ключей подписчиками.
- Продление подписки (ссылка на оплату — интеграция с ЮKassa/СБП/Crypto).
- Уведомления об окончании подписки.

### 9.2 Настройка через GUI
1. **Settings** → **Telegram Bot** (клик 1).
2. Ввод `Bot Token` от @BotFather (клик 2).
3. Настройка приветственного сообщения (клик 3).
4. Кнопка «Set Webhook» (клик 4).
5. Тестовое сообщение «Bot is running» (клик 5).

### 9.3 Команды бота
```
/start — приветствие, проверка подписки.
/keys — выдаёт список всех активных ключей (ссылки + QR-коды).
/extend — ссылка на оплату продления.
/status — срок окончания подписки, количество устройств.
/support — контакт поддержки.
```

### 9.4 API: Bot ↔ Server
Бот работает через вебхук на `POST /api/v1/bot/webhook`. Внутри бота Python-логика обращается к внутреннему REST API сервера (через `http://api:8080` внутри Docker-сети).

---

## 10. API спецификация (для Android-клиента и GUI)

### 10.1 Базовый URL и авторизация
- **Base URL:** `https://<server>:8443/api/v1`
- **Auth:** Bearer JWT для GUI. `X-Client-Key` для Android-клиента.
- **Content-Type:** `application/json`

### 10.2 Аутентификация администратора
```http
POST /auth/login
Body: { "email": "admin@priton.dev", "password": "..." }
Response: { "token": "jwt...", "refresh_token": "..." }
```

### 10.3 Управление пользователями (GUI)
```http
GET /users?page=1&limit=20&search=ivan&plan=premium
Headers: Authorization: Bearer <JWT>
Response:
{
  "data": [
    {
      "id": "uuid", "email": "...", "tg_id": 123456,
      "plan": "premium", "expires_at": "2026-12-31",
      "is_active": true, "devices_count": 3
    }
  ],
  "total": 150, "page": 1
}

POST /users
Body: { "email": "...", "plan": "premium", "duration_days": 30 }
Response: { "id": "uuid", "client_key": "prt_abc123...", "keys": [...] }

GET /users/:id/keys
Response: { "keys": [ { "protocol": "vless", "connection_string": "vless://...", "qr": "..." } ] }

POST /users/:id/renew
Body: { "duration_days": 30 }
Response: { "new_expires_at": "2027-01-30" }
```

### 10.4 API для Android-клиента (ключевой раздел)

#### A. Регистрация / Привязка ключа
```http
POST /client/auth
Headers: X-Client-Key: <CLIENT_KEY> (или пусто для нового free-режима)
Body: { "device_id": "android_uuid", "fcm_token": "..." }

Response (200):
{
  "client_key": "prt_abc123...", // сохранить в SharedPreferences
  "subscription": {
    "plan": "free", // или "premium"
    "expires_at": null,
    "max_devices": 1
  },
  "servers": [
    {
      "node_id": "uuid",
      "location": "Russia",
      "host": "185.x.x.x",
      "protocols": ["tor", "zapret", "free_vless"]
    }
  ]
}
```

#### B. Получение конфигов (всех протоколов)
```http
GET /client/configs
Headers: X-Client-Key: <CLIENT_KEY>

Response (200):
{
  "subscription": {
    "plan": "premium",
    "expires_at": "2026-12-31T00:00:00Z",
    "features": ["auto_switch", "split_tunnel", "tor_fallback", "zapret"]
  },
  "nodes": [
    {
      "node_id": "uuid1",
      "role": "master",
      "location": "Russia",
      "host": "185.x.x.x",
      "load_percent": 42,
      "protocols": [
        {
          "type": "amneziawg",
          "port": 33000,
          "config": { "Jc": 4, "Jmin": 40, ... },
          "connection_string": "..."
        },
        {
          "type": "vless",
          "port": 443,
          "config": { "id": "uuid", "flow": "xtls-rprx-vision", ... },
          "connection_string": "vless://..."
        },
        {
          "type": "hysteria2",
          "port": 443,
          "config": { "obfs": "salamander", ... },
          "connection_string": "hysteria2://..."
        }
      ]
    }
  ],
  "telegram_proxy": {
    "host": "185.x.x.x",
    "port": 443,
    "secret": "dd..."
  },
  "free_servers": [ // для free-режима
    {
      "node_id": "free_uuid",
      "host": "free.priton.dev",
      "protocol": "vless",
      "connection_string": "vless://free...",
      "speed_limit_mbps": 1
    }
  ]
}
```

#### C. Проверка соединения (health-check)
```http
GET /client/health
Headers: X-Client-Key: <CLIENT_KEY>

Response (200):
{
  "status": "ok",
  "server_time": "2026-07-14T12:00:00Z",
  "your_ip": "10.0.0.5",
  "node_status": [
    { "node_id": "uuid", "ping_ms": 45, "status": "online" }
  ]
}
```

#### D. Отчёт о подключении (для логов и аналитики)
```http
POST /client/connection-report
Headers: X-Client-Key: <CLIENT_KEY>
Body:
{
  "node_id": "uuid",
  "protocol": "vless",
  "connected_at": "2026-07-14T11:00:00Z",
  "disconnected_at": "2026-07-14T12:00:00Z",
  "tx_bytes": 5000000,
  "rx_bytes": 25000000,
  "error": null // или строка ошибки
}
Response: { "received": true }
```

#### E. Получение лучшей ноды (балансировка)
```http
GET /client/best-node?protocol=vless&region=auto
Headers: X-Client-Key: <CLIENT_KEY>
Response:
{
  "node_id": "uuid",
  "host": "...",
  "protocol_config": { ... },
  "reason": "lowest_latency" // или "least_load", "geo_proximity"
}
```

#### F. Управление подпиской (проверка статуса)
```http
GET /client/subscription
Headers: X-Client-Key: <CLIENT_KEY>
Response:
{
  "plan": "premium",
  "expires_at": "2026-12-31",
  "days_left": 169,
  "devices_used": 2,
  "devices_max": 5,
  "renewal_url": "https://..." // если интеграция с оплатой
}
```

#### G. Раздельное туннелирование (списки)
```http
GET /client/split-tunnel
Headers: X-Client-Key: <CLIENT_KEY>
Response:
{
  "mode": "blacklist", // или "whitelist"
  "apps": ["ru.sberbankonline", "com.vkontakte.android"], // Android package names
  "domains": ["*.ru", "*.рф"],
  "ips": ["10.0.0.0/8", "192.168.0.0/16"]
}
```

#### H. Обновление ключей (ротация)
```http
POST /client/rotate-keys
Headers: X-Client-Key: <CLIENT_KEY>
Body: { "protocols": ["vless", "amneziawg"] } // или ["all"]
Response:
{
  "new_keys": [
    { "protocol": "vless", "connection_string": "vless://new..." }
  ]
}
```

### 10.5 Коды ошибок API
```json
{
  "200": "OK",
  "400": "Bad Request — невалидный JSON или параметры",
  "401": "Unauthorized — невалидный X-Client-Key или JWT",
  "403": "Forbidden — подписка истекла или превышен лимит устройств",
  "404": "Not Found — пользователь или нода не найдены",
  "429": "Too Many Requests — rate limit",
  "500": "Internal Server Error"
}
```

---

## 11. Система логирования

### 11.1 Уровни логирования
- **INFO:** подключения пользователей, смена нод, выдача ключей.
- **WARN:** попытка авторизации с истёкшим ключом, перегрузка ноды (>90%).
- **ERROR:** падение VPN-ядра, ошибка связи master-slave, ошибка БД.
- **DEBUG:** детали API-запросов (включается отдельно).

### 11.2 Структура логов (JSON)
```json
{
  "timestamp": "2026-07-14T12:00:00Z",
  "level": "INFO",
  "service": "priton-api",
  "node_id": "uuid",
  "user_id": "uuid",
  "event": "USER_CONNECTED",
  "protocol": "vless",
  "ip": "185.x.x.x",
  "bytes_tx": 1024,
  "bytes_rx": 2048,
  "message": "User connected to node Russia-1"
}
```

### 11.3 Хранение и ротация
- Локально: `/var/log/priton/`, ротация через `logrotate` (7 дней).
- Внутри Docker: stdout → Loki (если включено в `docker-compose.monitoring.yml`).
- GUI: вкладка **Logs** с live tail (WebSocket `/ws/logs`).

### 11.4 API логов (для GUI)
```http
GET /logs?level=ERROR&node_id=uuid&limit=50&offset=0
Headers: Authorization: Bearer <JWT>
Response: { "logs": [ {...}, {...} ], "total": 1200 }
```

---

## 12. Безопасность
- **TLS 1.3** на всех публичных endpoint'ах (Caddy auto-TLS через Let's Encrypt или self-signed для IP).
- **JWT** с коротким TTL (15 мин) + refresh token (7 дней).
- **X-Client-Key:** 32-байтовый случайный ключ (формат `prt_<base64>`), хранится в БД в виде bcrypt-хеша для проверки, но в ответе отдаётся plaintext только при создании.
- **Rate Limiting:** 100 req/min для API, 10 req/min для auth.
- **Fail2ban:** встроенный механизм (или через Caddy) — блокировка IP при 5 неудачных попытках входа.
- **Секреты:** все пароли/ключи в `.env`, никогда не в коде.
- **Backup:** ежедневный дамп PostgreSQL в `/backups/` (хранение 7 дней).

---

## 13. Файловая структура проекта (для Copilot)
```
priton-core/
├── docker-compose.yml
├── docker-compose.monitoring.yml
├── install.sh
├── .env.example
├── backend/
│   ├── cmd/
│   │   ├── api/          # main.go (API + GUI embed)
│   │   └── cli/          # priton-cli
│   ├── internal/
│   │   ├── auth/         # JWT, middleware
│   │   ├── user/         # CRUD, подписки
│   │   ├── node/         # Master-slave логика
│   │   ├── protocol/     # Генерация конфигов
│   │   ├── client/       # API для Android
│   │   ├── log/          # Логирование
│   │   └── bot/          # Telegram bot webhook handler
│   ├── pkg/
│   │   ├── xray/         # Xray-core gRPC/HTTP API client
│   │   ├── amneziawg/    # WG keygen
│   │   └── hysteria/     # Hysteria2 config gen
│   └── web/
│       └── dist/         # Сборка React GUI (embed)
├── protocols/
│   ├── xray/
│   │   └── Dockerfile
│   ├── amneziawg/
│   │   └── Dockerfile
│   ├── hysteria2/
│   ├── mtproto/
│   └── sing-box/
├── bot/
│   ├── main.py
│   └── requirements.txt
└── migrations/
    └── 001_init.sql
```

---

## 14. Требования к железу (минимум)
- **Master:** 2 vCPU, 4 GB RAM, 20 GB SSD (для 500+ пользователей).
- **Slave (VPN-нода):** 1 vCPU, 2 GB RAM, 10 GB SSD + трафик.
- **OS:** Ubuntu 22.04/24.04 LTS, Debian 12.

---

## 15. Чек-лист приёмки (Definition of Done)
- [ ] `install.sh` отрабатывает на чистой Ubuntu 22.04 без ошибок за < 5 минут.
- [ ] GUI доступна по HTTPS, все разделы открываются за ≤ 5 кликов от Dashboard.
- [ ] Создание пользователя + выдача всех ключей происходит в GUI за 5 кликов.
- [ ] Telegram Bot отвечает на `/keys` и выдаёт рабочие конфиги.
- [ ] Master-Slave: добавление ноды через GUI работает, heartbeat корректен.
- [ ] Android-клиент (по ТЗ ниже) подключается по `X-Client-Key` без дополнительных проверок.
- [ ] Все 7 протоколов генерируют валидные конфиги и поднимаются в Docker.
- [ ] MTProto Proxy работает постоянно, независимо от подписок.
- [ ] Логи пишутся в JSON, доступны в GUI с фильтрами.
- [ ] Ротация ключей через API работает мгновенно.
