package node

import (
    "net/http"
    "github.com/gin-gonic/gin"
)

func ListHandler(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{"nodes": []gin.H{{"id": "node-1", "role": "master", "status": "active"}}})
}

func CreateHandler(c *gin.Context) {
    c.JSON(http.StatusCreated, gin.H{"id": "node-2", "status": "active"})
}
