package gin

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type CommonHandler struct {
	appName    string
	appVersion string
}

func NewCommonHandler(name, version string) *CommonHandler {
	return &CommonHandler{
		appName:    name,
		appVersion: version,
	}
}

func (h *CommonHandler) ShowSplash(c *gin.Context) {
	c.HTML(http.StatusOK, "common/splashpage", gin.H{
		"title": "Akisroc",
	})
}

func (h *CommonHandler) htmxRender(c *gin.Context, status int, partial string, data gin.H) {
	isHTMX, _ := c.Get("isHTMX")
	if isHTMX == true {
		c.HTML(status, partial, data)
		return
	}

	data["Partial"] = partial
	c.HTML(status, "layout/base", data)
}
