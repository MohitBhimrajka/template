# Full-Stack Web Application Template

A production-ready template for building modern web applications featuring a Python/FastAPI backend, Next.js/React frontend, and PostgreSQL database. All services are containerized with Docker for consistent development across platforms.

## Features

- **Production-Ready Stack**: FastAPI, Next.js, and PostgreSQL working together
- **Single-Command Deployment**: Deploy to Google Cloud Run with `./deployment/gcloud-deploy.sh`
- **Cross-Platform Compatibility**: Works on Windows, macOS, and Linux  
- **Clean Architecture**: Simplified codebase without authentication complexity
- **Containerized Development**: Docker and Docker Compose for consistent environments
- **Multiple Setup Options**: Docker, local development, or hybrid approaches
- **Developer Experience**: Code formatting, linting, and database migrations included
- **Health Monitoring**: Built-in health checks and monitoring for production environments

## Technology Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| Backend   | Python 3.11 with FastAPI | High-performance API development |
| Frontend  | Next.js 15 with React 19 & TypeScript | Modern user interface framework |
| Database  | PostgreSQL 15 / SQLite | Reliable relational database |
| DevOps    | Docker & Docker Compose | Containerization and orchestration |
| Deployment | Google Cloud Run | Serverless production hosting |
| Migrations | Alembic | Database schema management |
| Monitoring | Cloud Run Logging | Production observability |

## Prerequisites

Choose your preferred development approach:

### Option A: Docker Development (Recommended)
- [Docker Desktop](https://www.docker.com/products/docker-desktop) (Windows/Mac) or Docker Engine (Linux)
- [Git](https://git-scm.com/downloads)

### Option B: Local Development
- [Python 3.8+](https://www.python.org/downloads/)
- [Node.js 18+](https://nodejs.org/en/download/)
- [PostgreSQL 15+](https://www.postgresql.org/download/) (or Docker for database only)
- [Git](https://git-scm.com/downloads)

## Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd template
cp .env.example .env
```

### 2. Choose Your Setup Method

#### Option A: Production Deployment (Google Cloud)

Deploy directly to Google Cloud Run:

```bash
# Set up production environment
cp deployment/prod.example.env deployment/.env.prod
# Edit .env.prod with your Google Cloud project settings

# Deploy to Google Cloud Run
./deployment/gcloud-deploy.sh
```

#### Option B: Local Development

Choose your preferred local development method:

#### Method B1: Full Docker Setup (Recommended for Local)

**Windows (Command Prompt/PowerShell):**
```cmd
docker-compose up --build -d
```

**Windows (without make):**
```cmd
REM Start services
docker-compose up --build -d

REM View logs
docker-compose logs -f backend
docker-compose logs -f frontend

REM Stop services
docker-compose down
```

**macOS/Linux:**
```bash
make up
```

#### Method B2: Local Development Setup (Manual)

**Manual setup:**

1. **Backend Setup:**
   ```bash
   # Create virtual environment
   python -m venv venv
   
   # Activate (Windows)
   venv\Scripts\activate
   
   # Activate (macOS/Linux)
   source venv/bin/activate
   
   # Install dependencies
   pip install -r packages/requirements.txt
   ```

2. **Frontend Setup:**
   ```bash
   cd frontend
   npm install
   cd ..
   ```

3. **Database Setup** (choose one):
   - Local PostgreSQL installation
   - Docker database only: `docker run --name postgres -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres:15`
   - Managed service (AWS RDS, Google Cloud SQL, etc.)

4. **Configuration:**
   Edit `.env` file with your database connection details.

5. **Database Migration:**
   ```bash
   alembic upgrade head
   ```

## Production Database Migrations

### Automatic Migration on Startup

**Production Ready**: Database migrations run automatically when the application starts, ensuring your database schema is always up-to-date without manual intervention.

**How it works:**
1. Application starts and waits for database connection
2. Runs `alembic upgrade head` to apply any pending migrations  
3. Starts the web server (Gunicorn)

**Safety Features:**
- **Non-destructive**: Only applies new migrations, never destroys existing data
- **Timeout protection**: Migrations timeout after 10 minutes in production
- **Error handling**: Application fails to start if migrations fail
- **Logging**: Comprehensive logging of migration status and errors

### Migration Management Tools

Use the production-safe migration utilities:

```bash
# Check current migration status
python scripts/migration_utils.py status

# View migration history  
python scripts/migration_utils.py history

# Check for pending migrations
python scripts/migration_utils.py pending

# Validate migration files
python scripts/migration_utils.py validate

# View database connection info
python scripts/migration_utils.py info

# Manually apply migrations (with confirmation in production)
python scripts/migration_utils.py apply
```

### Creating New Migrations

```bash
# Auto-generate migration from model changes
alembic revision --autogenerate -m "Add user profiles table"

# Create empty migration for manual changes  
alembic revision -m "Add custom indexes"

# Review the generated migration file before committing
```

### Production Migration Best Practices

1. **Test migrations locally** before deploying to production
2. **Review auto-generated migrations** - Alembic may not catch everything  
3. **Backup database** before major schema changes
4. **Use blue-green deployments** for zero-downtime schema changes
5. **Monitor migration performance** - some changes can be slow on large tables

### Emergency Migration Rollback

```bash
# Rollback to previous migration
alembic downgrade -1

# Rollback to specific revision  
alembic downgrade <revision_id>

# View downgrade SQL without executing
alembic downgrade -1 --sql
```

6. **Start Services:**
   ```bash
   # Terminal 1: Backend
   uvicorn app.main:app --reload --port 8001
   
   # Terminal 2: Frontend
   cd frontend
   npm run dev
   ```

### 3. Access Your Application

- **Frontend**: http://localhost:3001
- **Backend API Documentation**: http://localhost:8001/docs

## Development Commands

### Docker-based Development

**Using make (macOS/Linux):**
```bash
make up          # Start all services
make down        # Stop all services
make logs-be     # View backend logs
make logs-fe     # View frontend logs
make format      # Format code
make lint        # Lint code
make test-be     # Run backend tests
```

**Without make (Windows or other systems):**
Use docker-compose commands directly:
```bash
docker-compose up --build -d     # Start services
docker-compose down              # Stop services  
docker-compose logs -f backend   # View backend logs
docker-compose logs -f frontend  # View frontend logs
```

### Local Development

**Backend commands:**
```bash
# Activate virtual environment first
source venv/bin/activate  # macOS/Linux
venv\Scripts\activate     # Windows

# Database migrations
alembic upgrade head      # Apply migrations
alembic downgrade -1      # Rollback one migration
alembic history          # View migration history

# Code quality
black app/               # Format code
isort app/               # Sort imports
flake8 app/              # Lint code

# Testing
pytest tests/            # Run tests

# Start development server
uvicorn app.main:app --reload --port 8001
```

**Frontend commands:**
```bash
cd frontend

npm run dev              # Start development server
npm run build            # Build for production
npm run start            # Start production server
npm run lint             # Lint code
npm run format           # Format code
```

## Utility Scripts

### Project Digest Generation

The `make_ingest.py` script helps generate comprehensive project digests using [gitingest](https://github.com/cyclotruc/gitingest). This is useful for:

- Creating project summaries for AI analysis
- Generating documentation snapshots
- Code review preparation

**Usage:**
```bash
# Generate digest of current directory
python make_ingest.py .

# Generate digest with custom output file
python make_ingest.py . my_project_digest.txt

# Generate digest excluding additional file types
python make_ingest.py . .log .tmp .backup
```

The script automatically excludes common non-essential files (node_modules, __pycache__, build artifacts, etc.) to focus on the core source code.

## Environment Configuration

The `.env` file contains all configuration. Copy `.env.example` to `.env` and customize as needed.

### Core Variables (Required)

```bash
# Application Environment
APP_ENV=development          # development, staging, production
BASE_PATH=                   # Optional subpath for reverse proxy
LOG_LEVEL=INFO              # DEBUG, INFO, WARNING, ERROR, CRITICAL

# Backend URLs and Ports
FRONTEND_URL=http://localhost:3001${BASE_PATH}
PORT=8000                   # Backend server port
INTERNAL_IP=0.0.0.0         # Server binding IP

# Frontend URLs
NEXT_PUBLIC_API_URL=http://localhost:8001
NEXT_PUBLIC_BASE_PATH=${BASE_PATH}
INTERNAL_API_URL=http://backend:8000  # Container-to-container communication

# Database Connection
POSTGRES_USER=user
POSTGRES_PASSWORD=password
POSTGRES_DB=app_db
POSTGRES_HOST=postgres      # Use 'localhost' for local PostgreSQL
POSTGRES_PORT=5432
DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}
```

### Production Variables (Optional)

```bash
# Production Server Configuration
GUNICORN_LOG_LEVEL=info     # Gunicorn-specific logging
WORKER_CONNECTIONS=1000     # Max connections per worker
GUNICORN_TIMEOUT=120        # Request timeout in seconds
# WEB_CONCURRENCY=1         # Number of worker processes

# Database Utilities
SKIP_DB_WAIT=false          # Skip database connection wait during startup
```

The `.env.example` file contains only the essential variables currently used by the application. Add additional environment variables as needed when implementing new features.

## Database Options

### Option 1: Docker Database (Recommended for Development)
```bash
docker run --name postgres \
  -e POSTGRES_USER=user \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=app_db \
  -p 5432:5432 \
  -d postgres:15
```

### Option 2: Local PostgreSQL Installation

**Windows:**
1. Download from https://www.postgresql.org/download/windows/
2. Install and set password for postgres user
3. Create database: `createdb app_db`

**macOS:**
```bash
brew install postgresql@15
brew services start postgresql@15
createdb app_db
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get install postgresql-15 postgresql-contrib
sudo -u postgres createdb app_db
```

### Option 3: Managed Database Services
- **AWS RDS**: Use PostgreSQL engine
- **Google Cloud SQL**: PostgreSQL instance
- **Azure Database**: PostgreSQL service
- **Digital Ocean**: Managed PostgreSQL

Update `DATABASE_URL` in `.env` with your connection string.

## Project Structure

```
.
├── app/                     # Python/FastAPI backend application
│   ├── core/               # Core utilities (database, logging)
│   ├── models/             # SQLAlchemy database models
│   ├── schemas/            # Pydantic schemas
│   └── main.py             # FastAPI application entry point
├── frontend/               # Next.js/React frontend application
│   ├── src/
│   │   ├── app/           # Next.js 13+ app directory
│   │   ├── components/    # Reusable React components
│   │   └── lib/          # Utility functions
│   └── package.json       # Node.js dependencies
├── deployment/            # Production deployment scripts and configuration
│   ├── README.md          #   Complete deployment guide
│   ├── prod.example.env   #   Production environment template
│   ├── gcloud-deploy.sh   #   Single-command Google Cloud deployment
│   ├── setup-cloudsql.sh  #   Cloud SQL database setup helper
│   └── cloudbuild.yaml    #   CI/CD pipeline configuration
├── scripts/                # Setup and utility scripts
├── alembic/               # Database migration files
├── make_ingest.py         # Utility script for generating project digests with gitingest
├── gunicorn/              # Gunicorn configuration files
├── packages/              # Python dependency files
├── tests/                 # Backend test suite
├── utils/                 # Shared utility scripts
├── docker-compose.yml     # Multi-service Docker configuration
├── Dockerfile            # Backend container definition
└── start_gunicorn.py     # Cross-platform application entrypoint
```

## Platform-Specific Notes

### Windows Development

1. **Line Endings**: Git may convert LF to CRLF. Configure Git:
   ```cmd
   git config --global core.autocrlf false
   ```

2. **PowerShell Execution Policy**: If running scripts fails:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Long Path Names**: Enable long path support in Windows 10/11:
   ```cmd
   # Run as Administrator
   reg add HKLM\SYSTEM\CurrentControlSet\Control\FileSystem /v LongPathsEnabled /t REG_DWORD /d 1
   ```

4. **Docker Desktop**: Ensure WSL2 backend is enabled for better performance.

### macOS Development

1. **Homebrew**: Install for easy package management:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Xcode Command Line Tools**: Required for some Python packages:
   ```bash
   xcode-select --install
   ```

### Linux Development

1. **Docker**: Install Docker and Docker Compose:
   ```bash
   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install docker.io docker-compose
   sudo usermod -aG docker $USER
   ```

2. **Python venv**: Ensure venv module is available:
   ```bash
   sudo apt-get install python3-venv
   ```

## Troubleshooting

### Common Setup Issues

**Database Connection Errors:**
- Verify PostgreSQL is running
- Check DATABASE_URL in `.env` file
- Ensure database exists: `createdb app_db`

**Port Already in Use:**
```bash
# Find process using port
lsof -i :8001        # macOS/Linux
netstat -ano | findstr :8001  # Windows

# Kill process or change port in configuration
```

**Docker Issues on Windows:**
- Enable WSL2 backend in Docker Desktop
- Increase memory allocation in Docker Desktop settings
- Use PowerShell or Command Prompt (not Git Bash) for Docker commands

**Permission Errors (Linux/macOS):**
```bash
sudo chown -R $USER:$USER .
chmod +x scripts/*.py
```

**Node.js/Python Version Issues:**
- Use Node Version Manager (nvm) for Node.js
- Use pyenv for Python version management

### Getting Help

1. Check the logs:
   ```bash
   docker-compose logs backend
   docker-compose logs frontend
   ```

2. Verify environment configuration:
   ```bash
   docker-compose config
   ```

3. Reset Docker environment:
   ```bash
   docker-compose down -v
   docker-compose up --build
   ```

## Production Deployment

### Google Cloud Run (Recommended)

Deploy your entire application to Google Cloud Run with a single command:

```bash
# 1. Set up your production environment
cp deployment/prod.example.env deployment/.env.prod
# Edit .env.prod with your project settings

# 2. Deploy to Google Cloud Run
./deployment/gcloud-deploy.sh
```

**What you get:**
- **Serverless**: Pay only for requests, automatic scaling
- **Managed Infrastructure**: Google Cloud handles scaling, SSL, and monitoring
- **HTTPS**: Automatic SSL certificates  
- **CI/CD Ready**: GitHub integration with Cloud Build
- **Monitoring**: Built-in logging, metrics, and error reporting
- **Production Features**: Health checks, error handling, and optimized configurations

**Key Features:**
- Automatic scaling from 0 to 1000+ instances based on traffic
- Built-in load balancing and SSL termination
- Integration with Google Cloud's monitoring and logging services
- Support for custom domains and advanced networking

**Full deployment guide:** [deployment/README.md](./deployment/README.md)

### Alternative Deployment Options

**Docker Compose (Development/Testing):**
```bash
docker-compose up --build
```

**Other Cloud Providers:**
- **AWS**: Use ECS/Fargate + RDS
- **Azure**: Use Container Instances + PostgreSQL
- **DigitalOcean**: Use App Platform + Managed Database
- **Heroku**: Use standard buildpacks + Heroku Postgres

For detailed instructions on other deployment methods, see the [deployment folder](./deployment/).

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit changes: `git commit -am 'Add feature'`
4. Push to branch: `git push origin feature-name`
5. Submit a Pull Request

## License

This template is provided as-is for educational and development purposes. Customize according to your project needs.