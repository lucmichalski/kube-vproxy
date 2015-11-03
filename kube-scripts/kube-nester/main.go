package main

import "github.com/gin-gonic/gin"

func main() {
    r := gin.Default()
    r.POST("/", func(c *gin.Context) {
        c.String(200, "ok")
    })
    r.GET("/ping", func(c *gin.Context) {
        c.String(200, "pong")
    })
    r.Run("127.0.0.1:8080") // listen and serve on 0.0.0.0:8080
}
