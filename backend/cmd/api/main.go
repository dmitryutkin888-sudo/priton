package main

import (
    "net/http"
    "os"
    "path/filepath"
    "github.com/gin-gonic/gin"
    "priton/backend/internal/auth"
    "priton/backend/internal/bot"
    "priton/backend/internal/client"
    "priton/backend/internal/log"
    "priton/backend/internal/node"
    "priton/backend/internal/protocol"
    "priton/backend/internal/user"
)

func main() {
    r := gin.Default()

    r.GET("/health", func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{"status": "ok"})
    })

    r.Static("/static", filepath.Join(".", "web", "static"))
    r.LoadHTMLFiles(filepath.Join(".", "web", "index.html"))
    r.GET("/", func(c *gin.Context) {
        c.HTML(http.StatusOK, "index.html", gin.H{})
    })

    api := r.Group("/api/v1")
    api.POST("/auth/login", auth.LoginHandler)

    users := api.Group("/users")
    users.GET("", user.ListHandler)
    users.POST("", user.CreateHandler)
    users.GET(":id/keys", user.KeysHandler)
    users.POST(":id/renew", user.RenewHandler)

    clientGroup := api.Group("/client")
    clientGroup.POST("/auth", client.AuthHandler)
    clientGroup.GET("/configs", client.ConfigsHandler)
    clientGroup.GET("/health", client.HealthHandler)
    clientGroup.POST("/connection-report", client.ConnectionReportHandler)
    clientGroup.GET("/best-node", client.BestNodeHandler)
    clientGroup.GET("/subscription", client.SubscriptionHandler)
    clientGroup.GET("/split-tunnel", client.SplitTunnelHandler)
    clientGroup.POST("/rotate-keys", client.RotateKeysHandler)

    api.GET("/nodes", node.ListHandler)
    api.POST("/nodes", node.CreateHandler)

    api.GET("/protocols", protocol.ListHandler)
    api.POST("/protocols", protocol.CreateHandler)

    api.GET("/logs", log.ListHandler)

    api.POST("/bot/webhook", bot.WebhookHandler)

    host := os.Getenv("HOST")
    if host == "" {
        host = "0.0.0.0"
    }
    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }
    _ = r.Run(host + ":" + port)
}
