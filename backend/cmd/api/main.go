package main

import (
    "fmt"
    "log"
    "net/http"
    "os"
)

func main() {
    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }

    webRoot := os.Getenv("WEB_ROOT")
    if webRoot == "" {
        webRoot = "./backend/web"
    }

    mux := http.NewServeMux()
    mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
        _, _ = w.Write([]byte("ok"))
    })
    mux.HandleFunc("/api/v1/auth/login", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")
        _, _ = w.Write([]byte(`{"token":"demo.jwt","refresh_token":"demo.refresh"}`))
    })
    mux.HandleFunc("/api/v1/client/auth", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")
        _, _ = w.Write([]byte(`{"client_key":"prt_demo","subscription":{"plan":"free","expires_at":null,"max_devices":1},"servers":[{"node_id":"node-1","location":"Russia","host":"127.0.0.1","protocols":["vless","amneziawg"]}]}`))
    })
    mux.HandleFunc("/api/v1/client/configs", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")
        _, _ = w.Write([]byte(`{"subscription":{"plan":"premium","expires_at":"2030-01-01T00:00:00Z","features":["auto_switch","split_tunnel"]},"nodes":[{"node_id":"node-1","role":"master","location":"Russia","host":"127.0.0.1","load_percent":25,"protocols":[{"type":"vless","port":443,"config":{"id":"demo"},"connection_string":"vless://demo@127.0.0.1:443"}]}],"telegram_proxy":{"host":"127.0.0.1","port":443,"secret":"demo"}}`))
    })
    mux.Handle("/", http.FileServer(http.Dir(webRoot)))

    fmt.Printf("listening on :%s\n", port)
    log.Fatal(http.ListenAndServe(":"+port, mux))
}
