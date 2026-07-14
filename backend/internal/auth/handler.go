package auth

import (
    "net/http"
    "github.com/gin-gonic/gin"
)

func LoginHandler(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{
        "token": "demo-jwt-token",
        "refresh_token": "demo-refresh-token",
    })
}
