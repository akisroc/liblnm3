.PHONY         =  help test run build
.DEFAULT_GOAL  =  help

ENTRYPOINT_HTTP = ./cmd/http/main.go
EXECUTABLE_DIR = bin
EXECUTABLE_NAME = akisroc

## --------------------------------
##     Main commands
## --------------------------------

help: ## Display this help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-20s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

generate:
	@echo "=> Generate SQLC code"
	sqlc generate

test: ## Test project
	go test -v -race ./...

run: generate ## Run project
	@echo "=> Run HTTP server"
	go run $(ENTRYPOINT_HTTP)

build: generate ## Build project
	@echo "=> Compile binary"
	go build -o $(EXECUTABLE_DIR)/$(EXECUTABLE_NAME) $(ENTRYPOINT_HTTP)

clean:
	@echo "=> Clean outputs"
	rm -rf $(EXECUTABLE_DIR)
