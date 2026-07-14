package bot

import (
    "net/http"
    "github.com/gin-gonic/gin"
)

func WebhookHandler(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{"status": "ok"})
}
