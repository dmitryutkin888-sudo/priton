package log

import (
    "net/http"
    "github.com/gin-gonic/gin"
)

func ListHandler(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{"logs": []gin.H{{"level": "INFO", "message": "service started"}}, "total": 1})
}
