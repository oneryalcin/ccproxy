.PHONY: up down restart logs shell clean restart-llm switch-to-litellm switch-to-router help

# Default target
help:
	@echo "Available commands:"
	@echo "  make up                 - Build and start all services (LiteLLM, Router, Claude Code)"
	@echo "  make down               - Stop all services"
	@echo "  make clean              - Stop services and remove volumes"
	@echo "  make logs               - Tail logs for all services"
	@echo "  make shell              - Enter the Claude Code container shell"
	@echo ""
	@echo "  make switch-to-router   - Configure Claude Code to use the Node.js Router (Port 3000)"
	@echo "  make switch-to-litellm  - Configure Claude Code to use LiteLLM (Port 4000)"
	@echo ""
	@echo "  make restart-llm        - Restart only the LiteLLM service"
	@echo "  make restart-router     - Restart only the Router service"

# Start all services in detached mode
up:
	docker compose up -d --build

# Stop the services
down:
	docker compose down

# Restart the LiteLLM service
restart-llm:
	docker compose restart litellm

# Restart the Router service
restart-router:
	docker compose restart router

# View logs for all services
logs:
	docker compose logs -f

# Open a bash shell inside the Claude Code container
shell:
	docker compose exec claude-code bash

# Remove containers, networks, and volumes
clean:
	docker compose down -v

# --- Switching Commands ---

# Configure Claude Code to use LiteLLM (Port 4000)
switch-to-litellm:
	@echo "Switching Claude Code to use LiteLLM (port 4000)..."
	GEMINI_API_KEY=$${GEMINI_API_KEY} ANTHROPIC_BASE_URL=http://litellm:4000 docker compose up -d --force-recreate claude-code

# Configure Claude Code to use Router (Port 3000)
switch-to-router:
	@echo "Switching Claude Code to use Router (port 3000)..."
	GEMINI_API_KEY=$${GEMINI_API_KEY} ANTHROPIC_BASE_URL=http://router:3000 docker compose up -d --force-recreate claude-code
