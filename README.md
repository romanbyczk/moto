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

- **Docker** & **Docker Compose**
- 8 Services: PostgreSQL, Redis, Django Backend, Next.js Frontend, Prometheus, Grafana, PostgreSQL Exporter, Redis Exporter

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
├── docker-compose.yml       # Multi-container orchestration
├── Makefile                 # Development commands
├── .env.example             # Environment variables template
└── README.md
```

## Quick Start

### Prerequisites

- **Docker** & **Docker Compose**
- **Make** (optional, but recommended)
- **Python 3.13** & **Node.js 24**

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
