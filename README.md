# LNM3 Project

Multi-service application with Phoenix backend, Nuxt frontend, and archive API, orchestrated with Nginx reverse proxy.

## Architecture

```
lnm3/
├── docker-compose.yml          # Global orchestration
├── infrastructure/
│   └── reverse_proxy/          # Nginx reverse proxy
└── services/
    ├── frontend/               # Nuxt frontend (Bun runtime)
    ├── platform/               # Platform API (Elixir/Phoenix/PostgreSQL)
    └── archive/                # Archive API (PHP/Symfony/SQLite)
```

## Quick Start

### Prerequisites

- Docker & Docker Compose
- (Optional) Elixir 1.15+ for local development

### Start All Services

```bash
# Start all services
docker-compose up

# Start in background
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

### Services & Access

All services are accessed through **Nginx reverse proxy** on port 80:

| Service | URL | Description |
|---------|-----|-------------|
| **Frontend** | http://www.localhost | Nuxt frontend application |
| **Platform API** | http://platform.localhost | Phoenix API backend |
| **Archive API** | http://archive.localhost | Legacy forum archives (read-only) |

> **Note**: For production, replace `.localhost` with your actual domain names.

### API Endpoints

**Platform API** - `http://platform.localhost`

```bash
# Register a new user
curl -X POST http://platform.localhost/register \
  -H "Content-Type: application/json" \
  -d '{"user":{"username":"john","email":"john@example.com","password":"password123"}}'

# Login
curl -X POST http://platform.localhost/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john@example.com","password":"password123"}'
```

**Archive API** - `http://archive.localhost`

```bash
# Get all topics
curl http://archive.localhost/topics

# Get specific topic
curl http://archive.localhost/topics/123
```

### Database Access

- System: PostgreSQL
- Server: `db`
- Username: `user`
- Password: `pass`
- Database: `lnm3_platform`

## Development

### Platform Service (Phoenix)

See [services/platform/README.md](services/platform/README.md) for detailed documentation.

```bash
cd services/platform

# Local development (without Docker)
mix deps.get
mix ecto.setup
mix phx.server

# Run tests
mix test

# Docker development
docker-compose up
```

### Environment Variables

Create a `.env` file at the root for custom configuration:

```bash
# Platform API
SECRET_KEY_BASE=your_secret_key_here
PHX_HOST=platform.localhost
CORS_ORIGINS=http://www.localhost,http://localhost

# Archive API
ARCHIVE_APP_SECRET=your_archive_secret_here

# Frontend
NUXT_PUBLIC_API_URL=http://platform.localhost
```

Generate secrets:
```bash
# Platform secret
cd services/platform && mix phx.gen.secret

# Archive secret (any random string)
openssl rand -hex 32
```

## Production Deployment

### Using Docker Compose

```bash
# Set environment variables
export SECRET_KEY_BASE=$(cd services/platform && mix phx.gen.secret)
export PHX_HOST=api.yourdomain.com
export CORS_ORIGINS=https://yourdomain.com

# Build and start
docker-compose build
docker-compose up -d

# Run migrations
docker-compose exec platform bin/platform eval "Platform.Release.migrate()"
```

### Individual Services

Each service can be deployed independently. See service-specific documentation:
- [Platform Service Docker Guide](services/platform/DOCKER_README.md)

## Project Status

### Implemented
- ✅ User registration & authentication
- ✅ Session management with secure tokens
- ✅ CORS configuration
- ✅ Database migrations & seeds (auto-run on startup)
- ✅ Comprehensive test suite (30+ tests)
- ✅ Docker & Docker Compose multi-service setup
- ✅ Nginx reverse proxy with subdomain routing
- ✅ Archive API (legacy forum read-only access)
- ✅ Frontend (Nuxt with Bun runtime)

### In Progress
- 🚧 Frontend-backend integration
- 🚧 Authentication middleware
- 🚧 Protected routes

## License

[Add your license here]
