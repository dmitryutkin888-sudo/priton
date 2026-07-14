package protocol

import (
    "net/http"
    "github.com/gin-gonic/gin"
)

func ListHandler(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{"protocols": []string{"amneziawg", "vless", "ss", "trojan", "hysteria2", "tuic", "mtproto"}})
}

func CreateHandler(c *gin.Context) {
    c.JSON(http.StatusCreated, gin.H{"status": "created"})
}
