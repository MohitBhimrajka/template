#!/bin/bash

# ===================================================================
#      LOCAL DEPLOYMENT TEST SCRIPT
# -------------------------------------------------------------------
#  Test your deployment configuration locally before deploying to
#  Google Cloud Run. Builds and runs Docker containers locally.
# ===================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEPLOYMENT_ENV_FILE="${SCRIPT_DIR}/.env.prod"

# Default ports
BACKEND_PORT=8001
FRONTEND_PORT=3001

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Test deployment configuration locally"
    echo ""
    echo "Options:"
    echo "  -b, --backend-only      Test only the backend"
    echo "  -f, --frontend-only     Test only the frontend"
    echo "  --backend-port PORT     Backend port (default: 8001)"
    echo "  --frontend-port PORT    Frontend port (default: 3001)"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                      # Test both backend and frontend"
    echo "  $0 --backend-only       # Test only backend"
    echo "  $0 --frontend-only      # Test only frontend"
}

load_environment() {
    if [[ -f "$DEPLOYMENT_ENV_FILE" ]]; then
        log_info "Loading environment from $DEPLOYMENT_ENV_FILE"
        set -a
        source "$DEPLOYMENT_ENV_FILE"
        set +a
    else
        log_warning "No .env.prod file found. Using defaults."
    fi
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker is not running"
        exit 1
    fi
}

build_backend() {
    log_info "Building backend Docker image..."
    
    cd "$PROJECT_ROOT"
    
    docker build \
        -t "local-backend:test" \
        -f Dockerfile \
        .
    
    log_success "Backend image built successfully"
}

build_frontend() {
    log_info "Building frontend Docker image..."
    
    cd "$PROJECT_ROOT/frontend"
    
    # Use localhost URLs for local testing
    docker build \
        -t "local-frontend:test" \
        --build-arg NEXT_PUBLIC_API_URL="http://localhost:${BACKEND_PORT}" \
        --build-arg NEXT_PUBLIC_BASE_PATH="" \
        -f Dockerfile \
        .
    
    log_success "Frontend image built successfully"
}

test_backend() {
    log_info "Starting backend container on port $BACKEND_PORT..."
    
    # Stop existing container if running
    docker stop local-backend-test 2>/dev/null || true
    docker rm local-backend-test 2>/dev/null || true
    
    # Start backend container
    docker run -d \
        --name local-backend-test \
        -p "$BACKEND_PORT:8000" \
        -e APP_ENV=development \
        -e LOG_LEVEL=DEBUG \
        -e DATABASE_URL="${DATABASE_URL:-sqlite:///./test.db}" \
        -e FRONTEND_URL="http://localhost:${FRONTEND_PORT}" \
        local-backend:test
    
    # Wait for startup
    log_info "Waiting for backend to start..."
    for i in {1..30}; do
        if curl -sf "http://localhost:$BACKEND_PORT/api/health" > /dev/null 2>&1; then
            log_success "Backend is running at http://localhost:$BACKEND_PORT"
            log_info "API Docs: http://localhost:$BACKEND_PORT/docs"
            return 0
        fi
        sleep 1
    done
    
    log_error "Backend failed to start"
    docker logs local-backend-test
    return 1
}

test_frontend() {
    log_info "Starting frontend container on port $FRONTEND_PORT..."
    
    # Stop existing container if running
    docker stop local-frontend-test 2>/dev/null || true
    docker rm local-frontend-test 2>/dev/null || true
    
    # Start frontend container
    docker run -d \
        --name local-frontend-test \
        -p "$FRONTEND_PORT:3000" \
        -e NODE_ENV=production \
        -e NEXT_PUBLIC_API_URL="http://localhost:${BACKEND_PORT}" \
        -e NEXT_PUBLIC_BASE_PATH="" \
        local-frontend:test
    
    # Wait for startup
    log_info "Waiting for frontend to start..."
    for i in {1..30}; do
        if curl -sf "http://localhost:$FRONTEND_PORT" > /dev/null 2>&1; then
            log_success "Frontend is running at http://localhost:$FRONTEND_PORT"
            return 0
        fi
        sleep 1
    done
    
    log_error "Frontend failed to start"
    docker logs local-frontend-test
    return 1
}

cleanup() {
    log_info "Cleaning up test containers..."
    
    docker stop local-backend-test 2>/dev/null || true
    docker rm local-backend-test 2>/dev/null || true
    docker stop local-frontend-test 2>/dev/null || true
    docker rm local-frontend-test 2>/dev/null || true
    
    # Remove test images
    docker rmi local-backend:test 2>/dev/null || true
    docker rmi local-frontend:test 2>/dev/null || true
}

print_summary() {
    echo -e "${GREEN}"
    echo "============================================================"
    echo "                 LOCAL TEST SUMMARY"
    echo "============================================================"
    echo -e "${NC}"
    
    if [[ "$TEST_BACKEND" == "true" ]]; then
        echo "🚀 Backend:  http://localhost:$BACKEND_PORT"
        echo "📚 API Docs: http://localhost:$BACKEND_PORT/docs"
    fi
    
    if [[ "$TEST_FRONTEND" == "true" ]]; then
        echo "🌐 Frontend: http://localhost:$FRONTEND_PORT"
    fi
    
    echo ""
    echo "🔧 Container Management:"
    echo "   docker logs local-backend-test   # View backend logs"
    echo "   docker logs local-frontend-test  # View frontend logs"
    echo "   docker stop local-backend-test local-frontend-test  # Stop containers"
    echo ""
    echo "Press Ctrl+C to stop all containers and clean up"
}

# Default values
TEST_BACKEND=true
TEST_FRONTEND=true

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--backend-only)
            TEST_FRONTEND=false
            shift
            ;;
        -f|--frontend-only)
            TEST_BACKEND=false
            shift
            ;;
        --backend-port)
            BACKEND_PORT="$2"
            shift 2
            ;;
        --frontend-port)
            FRONTEND_PORT="$2"
            shift 2
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

# Set up signal handlers for cleanup
trap cleanup EXIT
trap 'cleanup; exit 1' INT TERM

# Main execution
main() {
    echo -e "${BLUE}"
    echo "============================================================"
    echo "           LOCAL DEPLOYMENT TEST"
    echo "============================================================"
    echo -e "${NC}"
    
    load_environment
    check_docker
    
    # Build images
    if [[ "$TEST_BACKEND" == "true" ]]; then
        build_backend
    fi
    
    if [[ "$TEST_FRONTEND" == "true" ]]; then
        build_frontend
    fi
    
    # Test services
    if [[ "$TEST_BACKEND" == "true" ]]; then
        test_backend
    fi
    
    if [[ "$TEST_FRONTEND" == "true" ]]; then
        test_frontend
    fi
    
    print_summary
    
    # Keep containers running
    log_info "Containers are running. Press Ctrl+C to stop and clean up."
    
    # Wait indefinitely (until Ctrl+C)
    while true; do
        sleep 1
    done
}

main "$@"
