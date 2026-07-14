package user

import (
    "net/http"
    "github.com/gin-gonic/gin"
)

func ListHandler(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{
        "data": []gin.H{{"id": "demo-user", "email": "admin@priton.dev", "plan": "premium", "is_active": true}},
        "total": 1,
        "page": 1,
    })
}

func CreateHandler(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{
        "id": "demo-user",
        "client_key": "prt_demo_key",
        "keys": []gin.H{{"protocol": "vless", "connection_string": "vless://demo"}},
    })
}

func KeysHandler(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{
        "keys": []gin.H{{"protocol": "vless", "connection_string": "vless://demo", "qr": "demo-qr"}},
    })
}

func RenewHandler(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{"new_expires_at": "2027-01-01T00:00:00Z"})
}
