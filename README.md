# Full-Stack Web Application Template

A production-ready template for building modern web applications featuring a Python/FastAPI backend, Next.js/React frontend, and PostgreSQL database. All services are containerized with Docker for consistent development across platforms.

## Features

- **Production-Ready Stack**: FastAPI, Next.js, and PostgreSQL working together
- **Cross-Platform Compatibility**: Works on Windows, macOS, and Linux
- **Clean Architecture**: Simplified codebase without authentication complexity
- **Containerized Development**: Docker and Docker Compose for consistent environments
- **Multiple Setup Options**: Docker, local development, or hybrid approaches
- **Developer Experience**: Code formatting, linting, and database migrations included

## Technology Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| Backend   | Python 3.11 with FastAPI | High-performance API development |
| Frontend  | Next.js 15 with React 19 & TypeScript | Modern user interface framework |
| Database  | PostgreSQL 15 | Reliable relational database |
| DevOps    | Docker & Docker Compose | Containerization and orchestration |

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

#### Method A: Full Docker Setup

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

#### Method B: Local Development Setup

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

## Environment Configuration

The `.env` file contains all configuration. Key variables:

```bash
# Application
BASE_PATH=                    # Optional subpath for reverse proxy
LOG_LEVEL=INFO               # Logging level

# URLs
FRONTEND_URL=http://localhost:3001${BASE_PATH}
NEXT_PUBLIC_API_URL=http://localhost:8001
NEXT_PUBLIC_BASE_PATH=${BASE_PATH}

# Database
POSTGRES_USER=user
POSTGRES_PASSWORD=password
POSTGRES_DB=app_db
POSTGRES_HOST=postgres        # Use 'localhost' for local PostgreSQL
POSTGRES_PORT=5432
DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}
```

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
├── scripts/                # Setup and utility scripts
├── alembic/               # Database migration files
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

### Common Issues

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

For production deployment instructions, see [DEPLOYMENT.md](./docs/DEPLOYMENT.md).

Key considerations:
- Use managed database services
- Configure proper environment variables
- Enable HTTPS with reverse proxy
- Set up monitoring and logging
- Use container orchestration (Kubernetes, ECS, etc.)

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit changes: `git commit -am 'Add feature'`
4. Push to branch: `git push origin feature-name`
5. Submit a Pull Request

## License

This template is provided as-is for educational and development purposes. Customize according to your project needs.