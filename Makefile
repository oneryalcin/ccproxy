.PHONY: up down clean logs help shell-litellm shell-router

# Default target
help:
	@echo "Available commands:"
	@echo "  make shell-litellm      - Build & Run the Fused LiteLLM container (Python 3.12 + Claude Code)"
	@echo "  make shell-router       - Build & Run the Fused Router container (Node 20 + Claude Code)"
	@echo "  make up                 - Start all services in detached mode (Legacy distributed mode)"
	@echo "  make down               - Stop all services"
	@echo "  make clean              - Stop services and remove volumes"
	@echo "  make logs               - Tail logs"

# Fused Shell: LiteLLM
shell-litellm:
	docker compose run --rm --build fused-litellm

# Fused Shell: Router
shell-router:
	docker compose run --rm --build -e OPENROUTER_API_KEY=$${OPENROUTER_API_KEY} fused-router

# Legacy commands for distributed setup
up:
	docker compose up -d --build

down:
	docker compose down

logs:
	docker compose logs -f

clean:
	docker compose down -v