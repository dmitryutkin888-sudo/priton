package client

import (
    "net/http"
    "github.com/gin-gonic/gin"
)

func AuthHandler(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{
        "client_key": "prt_demo_key",
        "subscription": gin.H{"plan": "free", "expires_at": nil, "max_devices": 1},
        "servers": []gin.H{{"node_id": "node-1", "location": "Russia", "host": "127.0.0.1", "protocols": []string{"vless", "amneziawg"}}},
    })
}

func ConfigsHandler(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{
        "subscription": gin.H{"plan": "premium", "expires_at": "2026-12-31T00:00:00Z", "features": []string{"auto_switch", "zapret"}},
        "nodes": []gin.H{{"node_id": "node-1", "role": "master", "location": "Russia", "host": "127.0.0.1", "protocols": []gin.H{{"type": "vless", "port": 443, "config": gin.H{"id": "demo"}, "connection_string": "vless://demo"}}}},
        "telegram_proxy": gin.H{"host": "127.0.0.1", "port": 443, "secret": "demo"},
        "free_servers": []gin.H{{"node_id": "free", "host": "free.priton.dev", "protocol": "vless", "connection_string": "vless://free", "speed_limit_mbps": 1}},
    })
}

func HealthHandler(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{"status": "ok", "server_time": "2026-07-14T12:00:00Z", "your_ip": "127.0.0.1", "node_status": []gin.H{{"node_id": "node-1", "ping_ms": 45, "status": "online"}}})
}

func ConnectionReportHandler(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{"received": true})
}

func BestNodeHandler(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{"node_id": "node-1", "host": "127.0.0.1", "protocol_config": gin.H{"type": "vless"}, "reason": "least_load"})
}

func SubscriptionHandler(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{"plan": "premium", "expires_at": "2026-12-31", "days_left": 169, "devices_used": 2, "devices_max": 5, "renewal_url": "https://example.com"})
}

func SplitTunnelHandler(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{"mode": "blacklist", "apps": []string{"ru.sberbankonline"}, "domains": []string{"*.ru"}, "ips": []string{"10.0.0.0/8"}})
}

func RotateKeysHandler(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{"new_keys": []gin.H{{"protocol": "vless", "connection_string": "vless://new"}}})
}
