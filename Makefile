tags ?= all
host ?= localhost

.DEFAULT_GOAL := help
.PHONY: help start stop restart

help: ## Show this help message
	@echo "Usage: make [target] tags=[value] host=[value]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

start: ## Start services (use tags=... and host=... to filter)
	ansible-playbook services.yml -e "service_state=present" --tags "$(tags)" -l "$(host)"

stop: ## Stop services (use tags=... and host=... to filter)
	ansible-playbook services.yml -e "service_state=absent" --tags "$(tags)" -l "$(host)"

restart: stop start ## Restart services (stop then start)
