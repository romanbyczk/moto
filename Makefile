.PHONY: help build up down restart logs logs-backend logs-frontend logs-db logs-redis logs-prometheus logs-grafana shell-backend shell-frontend shell-redis migrate makemigrations createsuperuser test test-backend test-frontend clean clean-all ps health check install-hooks uninstall-hooks format lint status seed backup restore open-grafana open-prometheus check-tools install-tools az-login tf-init tf-plan tf-apply tf-destroy tf-output tf-validate tf-fmt tf-lint k8s-validate k8s-lint aks-credentials aks-deploy aks-status aks-logs-backend aks-logs-frontend aks-port-forward-grafana aks-port-forward-prometheus docker-build-prod deploy

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
	@echo "  $(GREEN)Prometheus:$(NC)       http://localhost:9090"
	@echo "  $(GREEN)Grafana:$(NC)          http://localhost:3001  (admin/admin)"

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
	@echo -n "Prometheus: "
	@curl -s http://localhost:9090/-/healthy > /dev/null && echo "$(GREEN)✓ Healthy$(NC)" || echo "$(RED)✗ Down$(NC)"
	@echo -n "Grafana: "
	@curl -s http://localhost:3001/api/health > /dev/null && echo "$(GREEN)✓ Healthy$(NC)" || echo "$(RED)✗ Down$(NC)"

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

logs-prometheus: ## Show Prometheus logs (follow)
	docker compose logs -f prometheus

logs-grafana: ## Show Grafana logs (follow)
	docker compose logs -f grafana

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

open-grafana: ## Open Grafana in browser
	@echo "$(BLUE)🌐 Opening Grafana...$(NC)"
	@command -v xdg-open > /dev/null && xdg-open http://localhost:3001 || \
	 command -v open > /dev/null && open http://localhost:3001 || \
	 echo "$(YELLOW)Please open http://localhost:3001 manually$(NC)"

open-prometheus: ## Open Prometheus in browser
	@echo "$(BLUE)🌐 Opening Prometheus...$(NC)"
	@command -v xdg-open > /dev/null && xdg-open http://localhost:9090 || \
	 command -v open > /dev/null && open http://localhost:9090 || \
	 echo "$(YELLOW)Please open http://localhost:9090 manually$(NC)"

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
	@echo "$(GREEN)Backend:$(NC)  Python 3.13 + Django 5.2 LTS + DRF 3.16 + PostgreSQL 18 + Redis 8"
	@echo "$(GREEN)Frontend:$(NC) React 19, Next.js 16, TypeScript 5, Tailwind CSS 4, pnpm 10.29.3"
	@echo "$(GREEN)Monitor:$(NC)  Prometheus 3.5.1 LTS + Grafana 12.3.3"
	@echo "$(GREEN)Infra:$(NC)    Docker Compose (8 services) / AKS (production)"
	@echo "$(GREEN)Packages:$(NC) Poetry (backend) + pnpm (frontend)"
	@echo ""
	@$(MAKE) --no-print-directory status

# ============================================================================
# Tools & Prerequisites
# ============================================================================

check-tools: ## Check if all required tools are installed
	@echo "$(BLUE)Checking required tools...$(NC)"
	@MISSING=0; \
	for tool in az terraform kubectl docker helm; do \
		if command -v $$tool > /dev/null 2>&1; then \
			echo "  $(GREEN)✓$(NC) $$tool ($$($$tool version 2>/dev/null | head -1))"; \
		else \
			echo "  $(RED)✗$(NC) $$tool - NOT INSTALLED"; \
			MISSING=1; \
		fi; \
	done; \
	for tool in kubeconform kube-linter tflint trivy; do \
		if command -v $$tool > /dev/null 2>&1; then \
			echo "  $(GREEN)✓$(NC) $$tool (optional)"; \
		else \
			echo "  $(YELLOW)~$(NC) $$tool - not installed (optional, run make install-tools)"; \
		fi; \
	done; \
	if [ $$MISSING -eq 1 ]; then \
		echo ""; \
		echo "$(RED)Required tools missing. Run: make install-tools$(NC)"; \
		exit 1; \
	fi; \
	echo ""; \
	echo "$(GREEN)All required tools installed!$(NC)"

install-tools: ## Install required CLI tools (az, terraform, kubectl, helm, validators)
	@echo "$(BLUE)Installing tools...$(NC)"
	@echo ""
	@# Azure CLI
	@if ! command -v az > /dev/null 2>&1; then \
		echo "$(YELLOW)Installing Azure CLI...$(NC)"; \
		curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash; \
	else \
		echo "$(GREEN)✓$(NC) Azure CLI already installed"; \
	fi
	@# Terraform
	@if ! command -v terraform > /dev/null 2>&1; then \
		echo "$(YELLOW)Installing Terraform...$(NC)"; \
		sudo apt-get update && sudo apt-get install -y gnupg software-properties-common; \
		wget -qO- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null; \
		echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $$(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list; \
		sudo apt-get update && sudo apt-get install -y terraform; \
	else \
		echo "$(GREEN)✓$(NC) Terraform already installed"; \
	fi
	@# kubectl
	@if ! command -v kubectl > /dev/null 2>&1; then \
		echo "$(YELLOW)Installing kubectl...$(NC)"; \
		curl -LO "https://dl.k8s.io/release/$$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"; \
		sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl; \
		rm -f kubectl; \
	else \
		echo "$(GREEN)✓$(NC) kubectl already installed"; \
	fi
	@# Helm
	@if ! command -v helm > /dev/null 2>&1; then \
		echo "$(YELLOW)Installing Helm...$(NC)"; \
		curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash; \
	else \
		echo "$(GREEN)✓$(NC) Helm already installed"; \
	fi
	@# kubeconform
	@if ! command -v kubeconform > /dev/null 2>&1; then \
		echo "$(YELLOW)Installing kubeconform...$(NC)"; \
		KUBECONFORM_VERSION=$$(curl -sL https://api.github.com/repos/yannh/kubeconform/releases/latest | grep tag_name | cut -d '"' -f 4); \
		curl -sL "https://github.com/yannh/kubeconform/releases/download/$${KUBECONFORM_VERSION}/kubeconform-linux-amd64.tar.gz" | sudo tar xz -C /usr/local/bin; \
	else \
		echo "$(GREEN)✓$(NC) kubeconform already installed"; \
	fi
	@# kube-linter
	@if ! command -v kube-linter > /dev/null 2>&1; then \
		echo "$(YELLOW)Installing kube-linter...$(NC)"; \
		KUBELINTER_VERSION=$$(curl -sL https://api.github.com/repos/stackrox/kube-linter/releases/latest | grep tag_name | cut -d '"' -f 4); \
		curl -sL "https://github.com/stackrox/kube-linter/releases/download/$${KUBELINTER_VERSION}/kube-linter-linux" -o /tmp/kube-linter; \
		sudo install -o root -g root -m 0755 /tmp/kube-linter /usr/local/bin/kube-linter; \
	else \
		echo "$(GREEN)✓$(NC) kube-linter already installed"; \
	fi
	@# tflint
	@if ! command -v tflint > /dev/null 2>&1; then \
		echo "$(YELLOW)Installing tflint...$(NC)"; \
		curl -sL https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash; \
	else \
		echo "$(GREEN)✓$(NC) tflint already installed"; \
	fi
	@# trivy
	@if ! command -v trivy > /dev/null 2>&1; then \
		echo "$(YELLOW)Installing trivy...$(NC)"; \
		sudo apt-get install -y wget apt-transport-https gnupg; \
		wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null; \
		echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee /etc/apt/sources.list.d/trivy.list; \
		sudo apt-get update && sudo apt-get install -y trivy; \
	else \
		echo "$(GREEN)✓$(NC) trivy already installed"; \
	fi
	@echo ""
	@echo "$(GREEN)All tools installed!$(NC)"

az-login: ## Login to Azure CLI
	@echo "$(BLUE)Logging in to Azure...$(NC)"
	az login
	@echo "$(GREEN)Azure login successful!$(NC)"

# ============================================================================
# Terraform
# ============================================================================

tf-validate: ## Validate Terraform configuration (no cloud credentials needed)
	@echo "$(BLUE)Validating Terraform configuration...$(NC)"
	cd terraform && terraform fmt -check -diff
	cd terraform && terraform validate
	@echo "$(GREEN)Terraform configuration valid!$(NC)"

tf-fmt: ## Format Terraform files
	@echo "$(BLUE)Formatting Terraform files...$(NC)"
	cd terraform && terraform fmt -recursive
	@echo "$(GREEN)Terraform files formatted!$(NC)"

tf-lint: ## Lint Terraform with tflint and trivy
	@echo "$(BLUE)Linting Terraform...$(NC)"
	@if command -v tflint > /dev/null 2>&1; then \
		echo "$(YELLOW)Running tflint...$(NC)"; \
		cd terraform && tflint --init && tflint; \
	else \
		echo "$(YELLOW)tflint not installed, skipping (run make install-tools)$(NC)"; \
	fi
	@if command -v trivy > /dev/null 2>&1; then \
		echo "$(YELLOW)Running trivy security scan...$(NC)"; \
		trivy config terraform/; \
	else \
		echo "$(YELLOW)trivy not installed, skipping (run make install-tools)$(NC)"; \
	fi
	@echo "$(GREEN)Terraform lint complete!$(NC)"

tf-init: ## Initialize Terraform
	@echo "$(BLUE)Initializing Terraform...$(NC)"
	cd terraform && terraform init
	@echo "$(GREEN)Terraform initialized!$(NC)"

tf-plan: ## Plan Terraform changes
	@echo "$(BLUE)Planning Terraform changes...$(NC)"
	cd terraform && terraform plan -out=tfplan
	@echo "$(GREEN)Plan complete! Review above.$(NC)"

tf-apply: ## Apply Terraform changes
	@echo "$(YELLOW)Applying Terraform changes...$(NC)"
	cd terraform && terraform apply tfplan
	@echo "$(GREEN)Infrastructure provisioned!$(NC)"

tf-destroy: ## Destroy all Azure infrastructure
	@echo "$(RED)This will DESTROY all Azure resources!$(NC)"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	cd terraform && terraform destroy
	@echo "$(GREEN)Infrastructure destroyed.$(NC)"

tf-output: ## Show Terraform outputs
	cd terraform && terraform output

# ============================================================================
# Kubernetes Validation
# ============================================================================

k8s-validate: ## Validate K8s manifests (dry-run + kubeconform)
	@echo "$(BLUE)Validating Kubernetes manifests...$(NC)"
	@if command -v kubeconform > /dev/null 2>&1; then \
		echo "$(YELLOW)Running kubeconform...$(NC)"; \
		find k8s -name '*.yaml' -not -name 'secrets.yaml.template' | xargs kubeconform -strict -summary -ignore-missing-schemas; \
	else \
		echo "$(YELLOW)kubeconform not installed, falling back to kubectl dry-run$(NC)"; \
		kubectl apply -f k8s/ --dry-run=client --recursive 2>&1 || true; \
	fi
	@echo "$(GREEN)K8s validation complete!$(NC)"

k8s-lint: ## Lint K8s manifests with kube-linter
	@echo "$(BLUE)Linting Kubernetes manifests...$(NC)"
	@if command -v kube-linter > /dev/null 2>&1; then \
		kube-linter lint k8s/; \
	else \
		echo "$(YELLOW)kube-linter not installed (run make install-tools)$(NC)"; \
	fi
	@echo "$(GREEN)K8s lint complete!$(NC)"

# ============================================================================
# AKS Deployment
# ============================================================================

aks-credentials: ## Get AKS credentials for kubectl
	@echo "$(BLUE)Fetching AKS credentials...$(NC)"
	az aks get-credentials \
		--resource-group $$(cd terraform && terraform output -raw resource_group_name) \
		--name $$(cd terraform && terraform output -raw aks_cluster_name) \
		--overwrite-existing
	@echo "$(GREEN)kubectl configured for AKS!$(NC)"

aks-deploy: ## Deploy all K8s manifests to AKS
	@echo "$(BLUE)Deploying to AKS...$(NC)"
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/network-policies.yaml
	kubectl apply -f k8s/monitoring/prometheus/
	kubectl apply -f k8s/monitoring/grafana/
	kubectl apply -f k8s/monitoring/postgres-exporter/
	kubectl apply -f k8s/monitoring/redis-exporter/
	kubectl apply -f k8s/backend/
	kubectl apply -f k8s/frontend/
	kubectl apply -f k8s/ingress/
	@echo "$(GREEN)Deployment complete!$(NC)"

aks-status: ## Show AKS deployment status
	@echo "$(BLUE)AKS Deployment Status:$(NC)"
	kubectl get all -n moto

aks-logs-backend: ## Tail backend pod logs
	kubectl logs -f -l app=backend -n moto

aks-logs-frontend: ## Tail frontend pod logs
	kubectl logs -f -l app=frontend -n moto

aks-port-forward-grafana: ## Port forward Grafana (localhost:3001)
	@echo "$(BLUE)Grafana available at http://localhost:3001$(NC)"
	kubectl port-forward svc/grafana 3001:3000 -n moto

aks-port-forward-prometheus: ## Port forward Prometheus (localhost:9090)
	@echo "$(BLUE)Prometheus available at http://localhost:9090$(NC)"
	kubectl port-forward svc/prometheus 9090:9090 -n moto

docker-build-prod: ## Build production Docker images locally
	@echo "$(BLUE)Building production images...$(NC)"
	docker build --target production -t moto-backend:prod ./backend
	docker build --target production -t moto-frontend:prod ./frontend
	@echo "$(GREEN)Production images built!$(NC)"

# ============================================================================
# Full Workflows
# ============================================================================

validate: ## Run all validations (terraform + k8s) without cloud credentials
	@echo "$(BLUE)Running all validations...$(NC)"
	@$(MAKE) --no-print-directory tf-validate
	@$(MAKE) --no-print-directory k8s-validate
	@echo "$(GREEN)All validations passed!$(NC)"

validate-all: ## Run all validations + linting + security scanning
	@echo "$(BLUE)Running full validation suite...$(NC)"
	@$(MAKE) --no-print-directory tf-validate
	@$(MAKE) --no-print-directory tf-lint
	@$(MAKE) --no-print-directory k8s-validate
	@$(MAKE) --no-print-directory k8s-lint
	@echo "$(GREEN)Full validation suite passed!$(NC)"

deploy: ## Full deployment workflow (validate, plan, apply, deploy to AKS)
	@echo "$(BLUE)Starting full deployment workflow...$(NC)"
	@$(MAKE) --no-print-directory check-tools
	@$(MAKE) --no-print-directory validate
	@$(MAKE) --no-print-directory tf-init
	@$(MAKE) --no-print-directory tf-plan
	@echo "$(YELLOW)Review the plan above. Press Enter to apply, Ctrl+C to cancel.$(NC)"
	@read confirm
	@$(MAKE) --no-print-directory tf-apply
	@$(MAKE) --no-print-directory docker-build-prod
	@$(MAKE) --no-print-directory aks-credentials
	@$(MAKE) --no-print-directory aks-deploy
	@$(MAKE) --no-print-directory aks-status
	@echo "$(GREEN)Full deployment complete!$(NC)"
