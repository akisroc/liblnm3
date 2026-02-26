package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func main() {
	router := gin.Default()
	router.LoadHTMLGlob("web/templates/**/*")
	router.GET("/", func(c *gin.Context) {
		c.HTML(http.StatusOK, "iam/splashpage.tmpl", gin.H{
			"title": "Akisroc",
		})
	})

	router.Run(":8080")
}
