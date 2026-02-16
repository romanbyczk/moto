# MOTO System

## Tech Stack

### Backend

- **Python 3.13**
- **Django 5.2**
- **Django REST Framework 3.16**
- **PostgreSQL 17** (TimescaleDB)
- **Redis 8** (Cache)

### Frontend

### Infrastructure

- **Docker** & **Docker Compose**
- 4 Services: PostgreSQL, Redis, Django Backend, Next.js Frontend

## Project Structure

```
.
├── backend/                 # Django REST API
│   ├── config/              # Django settings & configuration
│   ├── apps/                # Django apps (to be added)
│   ├── Dockerfile
│   ├── manage.py
├── frontend/                # Next.js application
│   ├── app/
│   │   ├── /page.tsx
│   ├── Dockerfile
│   ├── package.json
├── docker-compose.yml       # Multi-container orchestration
├── .env.example             # Environment variables template
└── README.md

```

## Quick Start

### Prerequisites

- **Docker** & **Docker Compose**
- **Make** (optional, but recommended)
- **Python 3.13** & **Node.js 24** (for local IDE support - optional)

### Using Makefile

The project includes a comprehensive Makefile with all common commands:

```bash
# Show all available commands
make help

# Start development environment
make up              # Start all services
make status          # Show service status
make logs            # Follow all logs

# Django management
make migrate         # Run migrations
make createsuperuser # Create admin user
make shell-backend   # Open Django shell
make health          # Check all services
make restart-backend # Quick backend restart


# Database & Cache
make dbshell         # Open PostgreSQL shell
make shell-redis     # Open Redis CLI

# Testing & Quality
make test            # Run all tests
make format          # Format code
make lint            # Run linters
make check           # Full quality check

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
- **Migrations**: Auto-applied on first run

### React Next.js Frontend (frontend)

- **Port**: 3000
- **Hot reload**: Enabled
- **Node modules**: Cached in Docker volume for performance
