package main

import (
    "encoding/json"
    "net/http"
    "os"
)

func handleConfig(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    _ = json.NewEncoder(w).Encode(map[string]any{
        "server": map[string]any{
            "name": "Priton Core",
            "domain": os.Getenv("PRITON_DOMAIN"),
            "http_port": 30385,
            "https_port": 30386,
        },
        "protocols": []map[string]any{
            {"name": "AmneziaWG", "enabled": true, "port": 33000},
            {"name": "VLESS", "enabled": true, "port": 443},
            {"name": "Shadowsocks", "enabled": true, "port": 8388},
            {"name": "Trojan", "enabled": true, "port": 8443},
            {"name": "Hysteria2", "enabled": true, "port": 8444},
            {"name": "TUIC", "enabled": true, "port": 8445},
            {"name": "MTProto", "enabled": true, "port": 443},
        },
    })
}
