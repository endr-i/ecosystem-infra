COMPOSE ?= docker compose

.PHONY: up down restart logs ps psql redis-cli clean databases

## Start postgres + redis and wait until they are healthy
up:
	@test -f .env || cp .env.example .env
	$(COMPOSE) up -d --wait
	@$(MAKE) --no-print-directory databases
	@echo "Infra is up. Network: ecosystem"

## Stop containers (data is kept)
down:
	$(COMPOSE) down

restart: down up

dev:
	@test -f .env || cp .env.example .env
	$(COMPOSE) -f compose.dev.yml up -d --wait
	@$(MAKE) --no-print-directory databases
	@echo "Dev stack is up. Network: ecosystem"

devdown:
	$(COMPOSE) -f compose.dev.yml down

devreset:
	$(COMPOSE) -f compose.dev.yml down -v

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

## Ensure the per-service databases exist (idempotent, also for existing volumes)
databases:
	$(COMPOSE) exec -T postgres bash /docker-entrypoint-initdb.d/01-create-databases.sh

psql:
	$(COMPOSE) exec postgres psql -U $${POSTGRES_USER:-postgres}

redis-cli:
	$(COMPOSE) exec redis redis-cli

## Stop containers AND delete all data volumes
clean:
	$(COMPOSE) down -v
