.DEFAULT_GOAL := help

.PHONY: help build up up-d down restart ps logs console migrate test shell clean \
        prod-build prod-up prod-down prod-ps prod-logs prod-console prod-migrate

PROD_COMPOSE := docker compose -f docker-compose.prod.yml --env-file .env.production

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

## ---- Production (docker compose, requires .env.production) ----

prod-build: ## Build production images (web, worker) from Dockerfile
	$(PROD_COMPOSE) build

prod-up: ## Start production stack detached (web, worker, db, redis)
	$(PROD_COMPOSE) up -d

prod-down: ## Stop production stack
	$(PROD_COMPOSE) down

prod-ps: ## Show production container status
	$(PROD_COMPOSE) ps

prod-logs: ## Tail production logs (optionally: make prod-logs s=web)
	$(PROD_COMPOSE) logs -f $(s)

prod-console: ## Open Rails console in the production web container
	$(PROD_COMPOSE) exec web bin/rails console

prod-migrate: ## Run pending migrations in the production web container
	$(PROD_COMPOSE) exec web bin/rails db:migrate

help: ## Show this help
	@echo "Development:"
	@grep -E '^(build|up|up-d|down|restart|ps|logs|console|migrate|test|shell|clean):.*## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*## "} {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Production:"
	@grep -E '^(prod-build|prod-up|prod-down|prod-ps|prod-logs|prod-console|prod-migrate):.*## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*## "} {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'
