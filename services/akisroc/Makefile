.PHONY         =  help test run build
.DEFAULT_GOAL  =  help

ENTRYPOINT = ./cmd/main.go
EXECUTABLE_NAME = akisroc

## --------------------------------
##     Main commands
## --------------------------------

help: ## Display this help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-20s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

test: ## Test project
	go test -v -race ./...

run: ## Run project
	go run $(ENTRYPOINT)

build: ## Build project
	go build -o $(EXECUTABLE_NAME) $(ENTRYPOINT)

