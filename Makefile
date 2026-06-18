.DEFAULT_GOAL := help

.PHONY: help build up up-d down restart ps logs console migrate test shell clean \
        prod-build prod-run prod-stop prod-logs

## ---- Development (docker compose) ----

build: ## Build dev images (web, worker)
	docker compose build

up: ## Start dev stack in the foreground (web, db, redis, worker)
	docker compose up

up-d: ## Start dev stack detached
	docker compose up -d

down: ## Stop dev stack
	docker compose down

restart: down up-d ## Restart dev stack (detached)

ps: ## Show dev container status
	docker compose ps

logs: ## Tail dev logs (optionally: make logs s=web)
	docker compose logs -f $(s)

console: ## Open Rails console in the web container
	docker compose exec web bin/rails console

migrate: ## Run pending migrations in the web container
	docker compose exec web bin/rails db:migrate

test: ## Run the RSpec suite in the web container
	docker compose exec web bundle exec rspec

shell: ## Open a shell in the web container
	docker compose exec web bash

clean: ## Stop dev stack and remove volumes (postgres_data, bundle_cache)
	docker compose down -v

## ---- Production (plain docker build/run) ----

prod-build: ## Build the production image from Dockerfile
	docker build -t web_e_commerce .

prod-run: ## Run the production image (requires config/master.key, or pass RAILS_MASTER_KEY=...)
	docker run -d -p 80:80 -e RAILS_MASTER_KEY=$${RAILS_MASTER_KEY:-$$(cat config/master.key)} --name web_e_commerce web_e_commerce

prod-stop: ## Stop and remove the production container
	docker stop web_e_commerce && docker rm web_e_commerce

prod-logs: ## Tail logs from the production container
	docker logs -f web_e_commerce

help: ## Show this help
	@echo "Development:"
	@grep -E '^(build|up|up-d|down|restart|ps|logs|console|migrate|test|shell|clean):.*## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*## "} {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Production:"
	@grep -E '^(prod-build|prod-run|prod-stop|prod-logs):.*## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*## "} {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'
