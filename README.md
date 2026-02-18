# MOTO System

## Tech Stack

### Backend

- **Python 3.13**
- **Django 5.2**
- **Django REST Framework 3.16**
- **PostgreSQL 18**
- **Redis 8** (Cache)

### Frontend

- **Next.js 16** (React 19)
- **TypeScript 5**
- **Tailwind CSS 4**

### Monitoring & Observability

- **Prometheus 3.5.1 LTS** (Metrics TSDB)
- **Grafana 12.3.3** (Dashboards)
- **django-prometheus 2.4** (Application metrics)
- **postgres_exporter 0.19** (PostgreSQL metrics)
- **redis_exporter 1.81** (Redis metrics)

### Infrastructure

- **Docker** & **Docker Compose** (local development)
- **Kubernetes** (AKS) — production orchestration with HPA, network policies, ingress
- **Terraform** (Azure) — AKS cluster, ACR, PostgreSQL Flexible Server, Redis Cache, VNet
- **GitHub Actions** — CI pipeline (lint, type check, test) + CD pipeline (build, push, deploy to AKS)

## Project Structure

```
.
├── backend/                 # Django REST API
│   ├── config/              # Django settings & configuration
│   ├── apps/                # Django apps (to be added)
│   ├── Dockerfile
│   └── manage.py
├── frontend/                # Next.js application
│   ├── app/
│   │   └── page.tsx
│   ├── Dockerfile
│   └── package.json
├── monitoring/              # Observability stack
│   ├── prometheus/
│   │   └── prometheus.yml   # Scrape configuration
│   └── grafana/
│       └── provisioning/    # Auto-provisioned datasources & dashboards
│           ├── datasources/
│           └── dashboards/
├── k8s/                    # Kubernetes manifests (AKS)
│   ├── namespace.yaml
│   ├── network-policies.yaml
│   ├── secrets.yaml.template
│   ├── backend/             # Deployment, Service, HPA
│   ├── frontend/            # Deployment, Service, HPA
│   ├── ingress/             # Ingress rules
│   └── monitoring/          # Prometheus, Grafana, exporters
├── terraform/               # Azure infrastructure (IaC)
│   ├── main.tf              # AKS, ACR, Resource Group
│   ├── network.tf           # VNet & subnets
│   ├── database.tf          # PostgreSQL Flexible Server
│   ├── redis.tf             # Azure Cache for Redis
│   ├── variables.tf
│   └── outputs.tf
├── .github/workflows/       # CI/CD pipelines
│   ├── ci.yml               # Lint, type check, test (PR)
│   └── deploy.yml           # Build, push, deploy to AKS (merge)
├── docker-compose.yml       # Local development orchestration
├── Makefile                 # Development commands
├── .env.example             # Environment variables template
└── README.md
```

## Quick Start

### Prerequisites

- **Docker** & **Docker Compose**
- **Make** (optional, but recommended)

For cloud deployment, additional tools are required:

- **Azure CLI** (`az`)
- **Terraform** (>= 1.5)
- **kubectl**
- **Helm**

Optional validation tools (recommended):

- **kubeconform** — K8s manifest schema validation
- **kube-linter** — K8s best-practice linting
- **tflint** — Terraform linting
- **trivy** — security scanning

```bash
# Check which tools are installed
make check-tools

# Install all required + optional tools (Ubuntu/Debian)
make install-tools
```

### Using Makefile

The project includes a comprehensive Makefile with all common commands:

```bash
# Show all available commands
make help

# Start development environment
make up              # Start all services
make status          # Show service status and URLs
make health          # Check all services health
make logs            # Follow all logs

# Django management
make migrate         # Run migrations
make createsuperuser # Create admin user
make shell-backend   # Open Django shell
make restart-backend # Quick backend restart

# Database & Cache
make dbshell         # Open PostgreSQL shell
make shell-redis     # Open Redis CLI

# Testing & Quality
make test            # Run all tests
make format          # Format code
make lint            # Run linters
make check           # Full quality check

# Monitoring
make open-grafana    # Open Grafana in browser
make open-prometheus # Open Prometheus in browser
make logs-prometheus # Follow Prometheus logs
make logs-grafana    # Follow Grafana logs

# Cleanup
make down            # Stop all services
make clean           # Stop + remove volumes
make prune           # Clean Docker resources
```

### Validation & Linting

Run validations locally without cloud credentials:

```bash
make validate        # Terraform fmt/validate + K8s manifest validation
make validate-all    # Above + tflint, trivy, kube-linter
```

Individual targets:

```bash
# Terraform
make tf-validate     # Format check + terraform validate
make tf-fmt          # Auto-format Terraform files
make tf-lint         # tflint + trivy security scan

# Kubernetes
make k8s-validate    # kubeconform (or kubectl dry-run fallback)
make k8s-lint        # kube-linter best-practice checks
```

## Services

### PostgreSQL (db)

- **Port**: 5432
- **Database**: moto
- **User**: admin
- **Password**: admin123
- **Status**: Includes healthcheck

### Redis (redis)

- **Port**: 6379
- **Eviction**: `allkeys-lru` (256MB limit)
- **Persistence**: RDB snapshots
- **Status**: Includes healthcheck

### Django Backend (backend)

- **Port**: 8000
- **Hot reload**: Enabled (development mode)
- **Metrics**: `/prometheus/metrics`

### React Next.js Frontend (frontend)

- **Port**: 3000
- **Hot reload**: Enabled
- **Node modules**: Cached in Docker volume for performance

### Prometheus (prometheus)

- **Port**: 9090
- **Retention**: 15 days / 5GB
- **Targets**: Django, PostgreSQL exporter, Redis exporter, self
- **Config reload**: `curl -X POST http://localhost:9090/-/reload`

### Grafana (grafana)

- **Port**: 3001
- **Credentials**: admin / admin
- **Dashboards**: Django, PostgreSQL, Redis (auto-provisioned)
- **Datasource**: Prometheus (auto-provisioned)

### PostgreSQL Exporter (postgres-exporter)

- **Port**: 9187
- **Metrics**: PostgreSQL connections, queries, locks, replication

### Redis Exporter (redis-exporter)

- **Port**: 9121
- **Metrics**: Memory, clients, hit/miss ratio, commands/sec

## CI/CD

### CI Pipeline (Pull Requests)

Runs on every PR to `main`/`master`:

- **Backend**: Ruff format & lint, Mypy type check, Pytest with coverage (≥85%)
- **Frontend**: ESLint, TypeScript check, tests

### CD Pipeline (Deploy to AKS)

Runs on merge to `main`/`master`:

1. Build & push Docker images to Azure Container Registry
2. Create/update Kubernetes secrets
3. Apply all K8s manifests with image tag substitution
4. Run database migrations (as a K8s Job)
5. Verify deployment rollout

## Kubernetes (AKS)

Production deployment on Azure Kubernetes Service:

- **Namespace**: `moto` with network policies for traffic isolation
- **Backend**: Deployment + Service + HPA (auto-scaling)
- **Frontend**: Deployment + Service + HPA (auto-scaling)
- **Ingress**: NGINX-based routing to backend/frontend
- **Monitoring**: Full Prometheus + Grafana stack with exporters
- **Secrets**: Managed via `secrets.yaml.template` (populated in CI/CD)

## Terraform (Azure Infrastructure)

Infrastructure as Code for the Azure environment:

| Resource | Description |
|---|---|
| Resource Group | `moto-prod-rg` |
| AKS Cluster | 2–4 nodes (`Standard_D2s_v3`), autoscaling, Azure CNI |
| Container Registry | ACR for Docker images |
| PostgreSQL | Flexible Server (v16, 32GB storage) |
| Redis | Azure Cache for Redis (Basic C1) |
| VNet | Dedicated subnets for AKS, PostgreSQL, Redis |

```bash
# Validate locally (no credentials needed)
make tf-validate

# Deploy infrastructure
make az-login        # Authenticate with Azure
make tf-init         # Initialize Terraform backend
make tf-plan         # Review planned changes
make tf-apply        # Apply changes
make tf-output       # Show resource connection details
```

## Deployment

### Full Workflow

The `deploy` target runs the entire pipeline end-to-end:

```bash
make deploy
```

This will: check tools → validate configs → `terraform init` → `terraform plan` → prompt for confirmation → `terraform apply` → build production Docker images → configure kubectl for AKS → deploy all K8s manifests.

### Step-by-Step

```bash
# 1. Install tools & authenticate
make install-tools
make az-login

# 2. Validate everything
make validate-all

# 3. Provision infrastructure
make tf-init
make tf-plan
make tf-apply

# 4. Build & deploy
make docker-build-prod
make aks-credentials
make aks-deploy

# 5. Verify
make aks-status
make aks-port-forward-grafana
```

### AKS Management

```bash
make aks-status                  # Show all resources in moto namespace
make aks-logs-backend            # Tail backend pod logs
make aks-logs-frontend           # Tail frontend pod logs
make aks-port-forward-grafana    # Grafana at localhost:3001
make aks-port-forward-prometheus # Prometheus at localhost:9090
```
