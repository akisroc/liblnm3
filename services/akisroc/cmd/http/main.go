package main

import (
	sharedgin "akisroc/internal/shared/infra/api/gin"
	"html/template"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/render"
)

func main() {
	router := gin.Default()

	router.SetFuncMap(template.FuncMap{
		"render": func(name string, data any) (template.HTML, error) {
			var buf strings.Builder
			err := router.HTMLRender.(render.HTMLProduction).Template.ExecuteTemplate(&buf, name, data)
			return template.HTML(buf.String()), err
		},
	})

	router.Use(sharedgin.HTMXMiddleware())

	router.Static("/assets", "./web/static")
	router.LoadHTMLGlob("web/templates/**/*")

	commonHandler := sharedgin.NewCommonHandler("AKISROC", "1.0.0")

	router.GET("/", commonHandler.ShowSplash)
	router.GET("/ping", func(c *gin.Context) {
		c.String(200, "pong")
	})

	router.Run(":8080")
}
