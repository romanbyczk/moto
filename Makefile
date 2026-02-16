.PHONY: help build up down restart logs logs-backend logs-frontend logs-db logs-redis shell-backend shell-frontend shell-redis migrate makemigrations createsuperuser test test-backend test-frontend clean clean-all ps health check install-hooks uninstall-hooks format lint status seed backup restore

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Default target
.DEFAULT_GOAL := help

help: ## Show this help message
	@echo "$(BLUE)╔═══════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║            MOTO System - Development Commands             ║$(NC)"
	@echo "$(BLUE)╚═══════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""

# ============================================================================
# Docker Management
# ============================================================================

build: ## Build all Docker containers
	@echo "$(BLUE)🔨 Building all containers...$(NC)"
	docker compose build
	@echo "$(GREEN)✓ Build completed!$(NC)"

up: ## Start all services
	@echo "$(BLUE)🚀 Starting all services...$(NC)"
	docker compose up -d
	@echo "$(GREEN)✓ All services started!$(NC)"
	@$(MAKE) --no-print-directory status

down: ## Stop all services
	@echo "$(YELLOW)⏹️  Stopping all services...$(NC)"
	docker compose down
	@echo "$(GREEN)✓ All services stopped!$(NC)"

restart: ## Restart all services
	@echo "$(YELLOW)🔄 Restarting all services...$(NC)"
	docker compose restart
	@echo "$(GREEN)✓ Services restarted!$(NC)"

restart-backend: ## Restart backend service only
	@echo "$(YELLOW)🔄 Restarting backend...$(NC)"
	docker compose restart backend
	@echo "$(GREEN)✓ Backend restarted!$(NC)"

restart-frontend: ## Restart frontend service only
	@echo "$(YELLOW)🔄 Restarting frontend...$(NC)"
	docker compose restart frontend
	@echo "$(GREEN)✓ Frontend restarted!$(NC)"

ps: ## Show running containers
	@echo "$(BLUE)📦 Running containers:$(NC)"
	@docker compose ps

status: ## Show detailed status of all services
	@echo "$(BLUE)📊 Service Status:$(NC)"
	@docker compose ps
	@echo ""
	@echo "$(BLUE)🔗 Available URLs:$(NC)"
	@echo "  $(GREEN)Frontend:$(NC)         http://localhost:3000"
	@echo "  $(GREEN)Backend API:$(NC)      http://localhost:8000"
	@echo "  $(GREEN)Health Check:$(NC)     http://localhost:8000/api/v1/health/"
	@echo "  $(GREEN)Swagger UI:$(NC)       http://localhost:8000/api/schema/swagger-ui/"
	@echo "  $(GREEN)Django Admin:$(NC)     http://localhost:8000/admin"
	@echo "  $(GREEN)PostgreSQL:$(NC)       localhost:5432"
	@echo "  $(GREEN)Redis:$(NC)            localhost:6379"

health: ## Check health of all services
	@echo "$(BLUE)❤️  Checking service health...$(NC)"
	@echo -n "Backend: "
	@curl -s http://localhost:8000/api/v1/health/ > /dev/null && echo "$(GREEN)✓ Healthy$(NC)" || echo "$(RED)✗ Down$(NC)"
	@echo -n "Frontend: "
	@curl -s http://localhost:3000/ > /dev/null && echo "$(GREEN)✓ Healthy$(NC)" || echo "$(RED)✗ Down$(NC)"
	@echo -n "PostgreSQL: "
	@docker compose exec -T db pg_isready -U admin -d moto > /dev/null && echo "$(GREEN)✓ Healthy$(NC)" || echo "$(RED)✗ Down$(NC)"
	@echo -n "Redis: "
	@docker compose exec -T redis redis-cli ping > /dev/null && echo "$(GREEN)✓ Healthy$(NC)" || echo "$(RED)✗ Down$(NC)"

# ============================================================================
# Logs
# ============================================================================

logs: ## Show logs from all services (follow)
	docker compose logs -f

logs-backend: ## Show backend logs (follow)
	docker compose logs -f backend

logs-frontend: ## Show frontend logs (follow)
	docker compose logs -f frontend

logs-db: ## Show database logs (follow)
	docker compose logs -f db

logs-redis: ## Show Redis logs (follow)
	docker compose logs -f redis

# ============================================================================
# Shell Access
# ============================================================================

shell-backend: ## Open Python shell in backend container
	@echo "$(BLUE)🐍 Opening Django shell...$(NC)"
	docker compose exec backend python manage.py shell

shell-db: ## Open PostgreSQL shell
	@echo "$(BLUE)🗄️  Opening PostgreSQL shell...$(NC)"
	docker compose exec db psql -U admin -d moto

shell-redis: ## Open Redis CLI
	@echo "$(BLUE)🗄️  Opening Redis CLI...$(NC)"
	docker compose exec redis redis-cli

bash-backend: ## Open bash in backend container
	docker compose exec backend bash

bash-frontend: ## Open bash in frontend container
	docker compose exec frontend sh

# ============================================================================
# Django Management
# ============================================================================

migrate: ## Run Django migrations
	@echo "$(BLUE)🔄 Running migrations...$(NC)"
	docker compose exec backend python manage.py migrate
	@echo "$(GREEN)✓ Migrations completed!$(NC)"

makemigrations: ## Create new Django migrations
	@echo "$(BLUE)📝 Creating migrations...$(NC)"
	docker compose exec backend python manage.py makemigrations
	@echo "$(GREEN)✓ Migrations created!$(NC)"

createsuperuser: ## Create Django superuser
	@echo "$(BLUE)👤 Creating superuser...$(NC)"
	docker compose exec backend python manage.py createsuperuser

showmigrations: ## Show Django migrations status
	docker compose exec backend python manage.py showmigrations

collectstatic: ## Collect static files
	@echo "$(BLUE)📦 Collecting static files...$(NC)"
	docker compose exec backend python manage.py collectstatic --noinput
	@echo "$(GREEN)✓ Static files collected!$(NC)"

# ============================================================================
# Database Management
# ============================================================================

dbshell: ## Open database shell
	docker compose exec backend python manage.py dbshell

dbreset: ## Reset database (drop + migrate)
	@echo "$(RED)⚠️  This will DELETE ALL DATA!$(NC)"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	@echo "$(YELLOW)🗑️  Dropping database...$(NC)"
	docker compose exec db psql -U admin -c "DROP DATABASE IF EXISTS moto;"
	docker compose exec db psql -U admin -c "CREATE DATABASE moto;"
	@echo "$(BLUE)🔄 Running migrations...$(NC)"
	docker compose exec backend python manage.py migrate
	@echo "$(GREEN)✓ Database reset complete!$(NC)"

# ============================================================================
# Testing
# ============================================================================

test: ## Run all tests (backend + frontend)
	@$(MAKE) --no-print-directory test-backend
	@$(MAKE) --no-print-directory test-frontend

test-backend: ## Run backend tests
	@echo "$(BLUE)🧪 Running backend tests...$(NC)"
	docker compose exec backend pytest

test-frontend: ## Run frontend tests
	@echo "$(BLUE)🧪 Running frontend tests...$(NC)"
	docker compose exec frontend pnpm test

test-backend-cov: ## Run backend tests with coverage
	@echo "$(BLUE)🧪 Running backend tests with coverage...$(NC)"
	docker compose exec backend pytest --cov --cov-report=html --cov-report=term

# ============================================================================
# Code Quality
# ============================================================================

format: ## Format code (ruff, prettier)
	@echo "$(BLUE)✨ Formatting code...$(NC)"
	@echo "$(YELLOW)Backend (ruff format):$(NC)"
	docker compose exec -T backend ruff format .
	docker compose exec -T backend ruff check --fix .
	@echo "$(YELLOW)Frontend (prettier):$(NC)"
	docker compose exec frontend pnpm exec prettier --write "app/**/*.{ts,tsx,css,json}"
	@echo "$(GREEN)✓ Code formatted!$(NC)"

lint: ## Run linters (ruff, eslint)
	@echo "$(BLUE)🔍 Running linters...$(NC)"
	@echo "$(YELLOW)Backend (ruff):$(NC)"
	docker compose exec -T backend ruff check .
	@echo "$(YELLOW)Frontend (eslint):$(NC)"
	docker compose exec frontend pnpm lint
	@echo "$(GREEN)✓ Linting complete!$(NC)"

type-check: ## Run type checkers (mypy, tsc)
	@echo "$(BLUE)🔍 Running type checkers...$(NC)"
	@echo "$(YELLOW)Backend (mypy):$(NC)"
	docker compose exec -T backend mypy .
	@echo "$(YELLOW)Frontend (tsc):$(NC)"
	docker compose exec frontend pnpm exec tsc --noEmit
	@echo "$(GREEN)✓ Type checking complete!$(NC)"

check: ## Run all quality checks (format, lint, type-check, test)
	@$(MAKE) --no-print-directory format
	@$(MAKE) --no-print-directory lint
	@$(MAKE) --no-print-directory type-check
	@$(MAKE) --no-print-directory test

# ============================================================================
# Git Hooks
# ============================================================================

install-hooks: ## Install git pre-commit hooks
	@echo "$(BLUE)🔗 Installing git hooks...$(NC)"
	@git config core.hooksPath .githooks
	@echo "$(GREEN)✓ Git hooks installed (.githooks/pre-commit)$(NC)"

uninstall-hooks: ## Remove git hooks configuration
	@echo "$(YELLOW)🔗 Removing git hooks...$(NC)"
	@git config --unset core.hooksPath || true
	@echo "$(GREEN)✓ Git hooks removed$(NC)"

# ============================================================================
# Development
# ============================================================================

init: ## Initialize project (build, migrate, create superuser)
	@echo "$(BLUE)🚀 Initializing project...$(NC)"
	@$(MAKE) --no-print-directory build
	@$(MAKE) --no-print-directory up
	@echo "$(YELLOW)⏳ Waiting for services to be healthy...$(NC)"
	@sleep 10
	@$(MAKE) --no-print-directory migrate
	@echo "$(BLUE)👤 Create a superuser:$(NC)"
	@$(MAKE) --no-print-directory createsuperuser
	@echo "$(GREEN)✓ Project initialized!$(NC)"
	@$(MAKE) --no-print-directory status


install: ## Install dependencies (rebuild containers)
	@echo "$(BLUE)📦 Installing dependencies...$(NC)"
	docker compose down
	docker compose build --no-cache
	docker compose up -d
	@echo "$(GREEN)✓ Dependencies installed!$(NC)"

update: ## Update dependencies (rebuild containers)
	@$(MAKE) --no-print-directory install

# ============================================================================
# Cleanup
# ============================================================================

clean: ## Stop containers and remove volumes
	@echo "$(YELLOW)🧹 Cleaning up...$(NC)"
	docker compose down -v
	@echo "$(GREEN)✓ Cleanup complete!$(NC)"

clean-all: ## Remove everything (containers, volumes, images)
	@echo "$(RED)⚠️  This will remove ALL containers, volumes, and images!$(NC)"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	docker compose down -v --rmi all --remove-orphans
	@echo "$(GREEN)✓ Complete cleanup done!$(NC)"

clean-logs: ## Clear all log files
	@echo "$(YELLOW)🧹 Clearing logs...$(NC)"
	docker compose down
	rm -rf backend/*.log frontend/*.log
	@echo "$(GREEN)✓ Logs cleared!$(NC)"

prune: ## Remove unused Docker resources
	@echo "$(YELLOW)🧹 Pruning Docker resources...$(NC)"
	docker system prune -f
	@echo "$(GREEN)✓ Docker pruned!$(NC)"

# ============================================================================
# CI/CD & Deployment
# ============================================================================

ci-test: ## Run CI tests (same as CI pipeline)
	@echo "$(BLUE)🔄 Running CI tests...$(NC)"
	docker compose -f docker-compose.yml up -d
	@sleep 10
	docker compose exec -T backend pytest --cov --cov-fail-under=85
	docker compose exec -T frontend pnpm test:ci
	@echo "$(GREEN)✓ CI tests passed!$(NC)"

# ============================================================================
# Utilities
# ============================================================================

open: ## Open application in browser
	@echo "$(BLUE)🌐 Opening application...$(NC)"
	@command -v xdg-open > /dev/null && xdg-open http://localhost:3000 || \
	 command -v open > /dev/null && open http://localhost:3000 || \
	 echo "$(YELLOW)Please open http://localhost:3000 manually$(NC)"

open-admin: ## Open Django admin in browser
	@echo "$(BLUE)🌐 Opening Django admin...$(NC)"
	@command -v xdg-open > /dev/null && xdg-open http://localhost:8000/admin || \
	 command -v open > /dev/null && open http://localhost:8000/admin || \
	 echo "$(YELLOW)Please open http://localhost:8000/admin manually$(NC)"

open-swagger: ## Open Swagger UI in browser
	@echo "$(BLUE)🌐 Opening Swagger UI...$(NC)"
	@command -v xdg-open > /dev/null && xdg-open http://localhost:8000/api/schema/swagger-ui/ || \
	 command -v open > /dev/null && open http://localhost:8000/api/schema/swagger-ui/ || \
	 echo "$(YELLOW)Please open http://localhost:8000/api/schema/swagger-ui/ manually$(NC)"

watch-frontend: ## Watch frontend bundle size
	docker compose exec frontend pnpm watch

watch-backend: ## Watch backend with auto-reload (already enabled by default)
	@echo "$(GREEN)✓ Backend auto-reload is enabled by default in development$(NC)"

# ============================================================================
# Information
# ============================================================================

info: ## Show project information
	@echo "$(BLUE)╔═══════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║        MOTO System - Development Commands                 ║$(NC)"
	@echo "$(BLUE)╚═══════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)Backend:$(NC)  Python 3.13 + Django 5.2 LTS + DRF 3.16 + PostgreSQL 17 + Redis 8"
	@echo "$(GREEN)Frontend:$(NC) React 19, Next.js 16, TypeScript 5, Tailwind CSS 4, pnpm 10.29.3"
	@echo "$(GREEN)Infra:$(NC)    Docker Compose (db, redis, backend, frontend)"
	@echo "$(GREEN)Packages:$(NC) Poetry (backend) + pnpm (frontend)"
	@echo ""
	@$(MAKE) --no-print-directory status
