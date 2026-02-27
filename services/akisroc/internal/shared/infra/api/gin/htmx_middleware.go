package gin

import "github.com/gin-gonic/gin"

func HTMXMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		isHTMX := c.GetHeader("HX-Request") == "true"
		c.Set("isHTMX", isHTMX)
		c.Next()
	}
}
