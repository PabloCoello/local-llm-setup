.PHONY: help setup start stop restart logs status test clean pull-models

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Run initial setup (creates .env, SSL certs, starts services)
	@echo "Running setup..."
	@./setup.sh

start: ## Start all services
	@echo "Starting services..."
	@docker-compose up -d
	@echo "Services started!"
	@make status

stop: ## Stop all services
	@echo "Stopping services..."
	@docker-compose down
	@echo "Services stopped!"

restart: ## Restart all services
	@echo "Restarting services..."
	@docker-compose restart
	@echo "Services restarted!"

logs: ## View logs (follow mode)
	@docker-compose logs -f

status: ## Show status of all services
	@echo "Service Status:"
	@docker-compose ps

test: ## Test API connectivity
	@echo "Testing API..."
	@./scripts/test-api.sh

clean: ## Remove all containers, volumes, and generated files (CAUTION: removes downloaded models!)
	@echo "WARNING: This will remove all containers, volumes, and downloaded models!"
	@read -p "Are you sure? (yes/no): " confirm && [ "$$confirm" = "yes" ] || exit 1
	@docker-compose down -v
	@rm -f config/.htpasswd config/ssl/*.pem .env
	@echo "Cleanup complete!"

pull-models: ## Interactive model downloader
	@./scripts/pull-models.sh

models: ## List downloaded models
	@echo "Downloaded models:"
	@docker exec ollama ollama list

gpu: ## Check GPU usage
	@echo "GPU Status:"
	@docker exec ollama nvidia-smi

api-key: ## Show API key from .env
	@if [ -f .env ]; then \
		grep LITELLM_MASTER_KEY .env; \
	else \
		echo "No .env file found. Run 'make setup' first."; \
	fi

health: ## Check health of all services
	@echo "Checking service health..."
	@echo -n "Ollama: "
	@curl -s http://localhost:11434/api/version > /dev/null && echo "✓ OK" || echo "✗ FAILED"
	@echo -n "LiteLLM: "
	@curl -s http://localhost:4000/health > /dev/null && echo "✓ OK" || echo "✗ FAILED"
	@echo -n "Nginx: "
	@curl -s -k https://localhost > /dev/null && echo "✓ OK" || echo "✗ FAILED"

update: ## Update Docker images
	@echo "Updating Docker images..."
	@docker-compose pull
	@echo "Update complete. Run 'make restart' to use new images."

backup: ## Backup models and configuration
	@echo "Creating backup..."
	@mkdir -p backups
	@docker run --rm -v local-llm-setup_ollama_data:/data -v $(PWD)/backups:/backup \
		alpine tar czf /backup/ollama-models-$(shell date +%Y%m%d-%H%M%S).tar.gz /data
	@cp -r config backups/config-$(shell date +%Y%m%d-%H%M%S)
	@cp .env backups/.env-$(shell date +%Y%m%d-%H%M%S) 2>/dev/null || true
	@echo "Backup complete! Check backups/ directory"

restore: ## Restore from backup (requires BACKUP_FILE variable)
	@if [ -z "$(BACKUP_FILE)" ]; then \
		echo "Error: Please specify BACKUP_FILE variable"; \
		echo "Example: make restore BACKUP_FILE=backups/ollama-models-20240101-120000.tar.gz"; \
		exit 1; \
	fi
	@echo "Restoring from $(BACKUP_FILE)..."
	@docker run --rm -v local-llm-setup_ollama_data:/data -v $(PWD)/backups:/backup \
		alpine tar xzf /backup/$(shell basename $(BACKUP_FILE)) -C /
	@echo "Restore complete!"

install-deps: ## Install system dependencies (Ubuntu/Debian)
	@echo "Installing system dependencies..."
	@sudo apt-get update
	@sudo apt-get install -y docker.io docker-compose openssl apache2-utils curl jq
	@echo "Dependencies installed!"
	@echo "Note: You may need to install NVIDIA Docker Runtime separately"
	@echo "See docs/SETUP.md for details"
