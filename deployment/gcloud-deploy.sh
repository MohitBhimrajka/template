#!/bin/bash

# ===================================================================
#      GOOGLE CLOUD RUN DEPLOYMENT SCRIPT
# -------------------------------------------------------------------
#  Single-command deployment for FastAPI + Next.js to Google Cloud Run
#  Deploys both backend and frontend services with proper configuration
# ===================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEPLOYMENT_ENV_FILE="${SCRIPT_DIR}/.env.prod"

# Default values
BUILD_BACKEND=true
BUILD_FRONTEND=true
DEPLOY_BACKEND=true
DEPLOY_FRONTEND=true
SKIP_CONFIRMATION=false

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

print_header() {
    echo -e "${BLUE}"
    echo "============================================================"
    echo "          GOOGLE CLOUD RUN DEPLOYMENT SCRIPT"
    echo "============================================================"
    echo -e "${NC}"
}

print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Deploy FastAPI backend and Next.js frontend to Google Cloud Run"
    echo ""
    echo "Options:"
    echo "  -b, --backend-only      Deploy only the backend service"
    echo "  -f, --frontend-only     Deploy only the frontend service"
    echo "  -y, --yes              Skip confirmation prompts"
    echo "  --no-build             Skip Docker image building"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Environment:"
    echo "  Create ${SCRIPT_DIR}/.env.prod with your configuration"
    echo "  (Copy from prod.example.env and customize)"
    echo ""
    echo "Examples:"
    echo "  $0                      # Deploy both backend and frontend"
    echo "  $0 --backend-only       # Deploy only backend"
    echo "  $0 --frontend-only      # Deploy only frontend"
    echo "  $0 --yes                # Deploy without confirmation"
}

load_environment() {
    if [[ ! -f "$DEPLOYMENT_ENV_FILE" ]]; then
        log_error "Environment file not found: $DEPLOYMENT_ENV_FILE"
        log_info "Copy prod.example.env to .env.prod and customize it with your settings"
        exit 1
    fi

    log_info "Loading environment from $DEPLOYMENT_ENV_FILE"
    
    # Load environment variables
    set -a  # Automatically export all variables
    source "$DEPLOYMENT_ENV_FILE"
    set +a  # Stop auto-exporting
    
    # Validate required variables
    local required_vars=(
        "GOOGLE_CLOUD_PROJECT"
        "GOOGLE_CLOUD_REGION"
        "BACKEND_SERVICE_NAME"
        "FRONTEND_SERVICE_NAME"
    )
    
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            log_error "Required environment variable $var is not set"
            exit 1
        fi
    done
    
    log_success "Environment loaded successfully"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if gcloud is installed
    if ! command -v gcloud &> /dev/null; then
        log_error "Google Cloud SDK (gcloud) is not installed"
        log_info "Install from: https://cloud.google.com/sdk/docs/install"
        exit 1
    fi
    
    # Check if Docker is running
    if ! docker info &> /dev/null; then
        log_error "Docker is not running or not installed"
        log_info "Please start Docker and try again"
        exit 1
    fi
    
    # Check gcloud authentication
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -1 &> /dev/null; then
        log_error "No active gcloud authentication found"
        log_info "Run: gcloud auth login"
        exit 1
    fi
    
    # Set the project
    log_info "Setting Google Cloud project to: $GOOGLE_CLOUD_PROJECT"
    gcloud config set project "$GOOGLE_CLOUD_PROJECT"
    
    # Enable required APIs
    log_info "Enabling required Google Cloud APIs..."
    gcloud services enable run.googleapis.com
    gcloud services enable cloudbuild.googleapis.com
    gcloud services enable sql-component.googleapis.com
    
    log_success "Prerequisites check completed"
}

show_deployment_summary() {
    echo -e "${YELLOW}"
    echo "============================================================"
    echo "                 DEPLOYMENT SUMMARY"
    echo "============================================================"
    echo -e "${NC}"
    echo "Project:         $GOOGLE_CLOUD_PROJECT"
    echo "Region:          $GOOGLE_CLOUD_REGION"
    echo ""
    if [[ "$DEPLOY_BACKEND" == "true" ]]; then
        echo "Backend Service: $BACKEND_SERVICE_NAME"
        echo "Backend Image:   gcr.io/$GOOGLE_CLOUD_PROJECT/backend:$BACKEND_IMAGE_TAG"
    fi
    if [[ "$DEPLOY_FRONTEND" == "true" ]]; then
        echo "Frontend Service: $FRONTEND_SERVICE_NAME"
        echo "Frontend Image:   gcr.io/$GOOGLE_CLOUD_PROJECT/frontend:$FRONTEND_IMAGE_TAG"
    fi
    echo ""
    
    if [[ "$SKIP_CONFIRMATION" != "true" ]]; then
        read -p "Do you want to proceed with deployment? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Deployment cancelled"
            exit 0
        fi
    fi
}

build_backend() {
    if [[ "$BUILD_BACKEND" != "true" ]]; then
        return 0
    fi
    
    log_info "Building backend Docker image..."
    
    cd "$PROJECT_ROOT"
    
    # Build the backend image
    docker build \
        --platform linux/amd64 \
        -t "gcr.io/$GOOGLE_CLOUD_PROJECT/backend:$BACKEND_IMAGE_TAG" \
        -f Dockerfile \
        .
    
    # Push to Google Container Registry
    log_info "Pushing backend image to Google Container Registry..."
    docker push "gcr.io/$GOOGLE_CLOUD_PROJECT/backend:$BACKEND_IMAGE_TAG"
    
    log_success "Backend image built and pushed successfully"
}

build_frontend() {
    if [[ "$BUILD_FRONTEND" != "true" ]]; then
        return 0
    fi
    
    log_info "Building frontend Docker image..."
    
    cd "$PROJECT_ROOT/frontend"
    
    # Build the frontend image
    docker build \
        --platform linux/amd64 \
        -t "gcr.io/$GOOGLE_CLOUD_PROJECT/frontend:$FRONTEND_IMAGE_TAG" \
        --build-arg NEXT_PUBLIC_API_URL="$NEXT_PUBLIC_API_URL" \
        --build-arg NEXT_PUBLIC_BASE_PATH="$NEXT_PUBLIC_BASE_PATH" \
        -f Dockerfile \
        .
    
    # Push to Google Container Registry
    log_info "Pushing frontend image to Google Container Registry..."
    docker push "gcr.io/$GOOGLE_CLOUD_PROJECT/frontend:$FRONTEND_IMAGE_TAG"
    
    log_success "Frontend image built and pushed successfully"
}

deploy_backend() {
    if [[ "$DEPLOY_BACKEND" != "true" ]]; then
        return 0
    fi
    
    log_info "Deploying backend to Cloud Run..."
    
    # Prepare Cloud Run deployment command using array for security
    local deploy_cmd=(
        "gcloud" "run" "deploy" "$BACKEND_SERVICE_NAME"
        "--image=gcr.io/$GOOGLE_CLOUD_PROJECT/backend:$BACKEND_IMAGE_TAG"
        "--region=$GOOGLE_CLOUD_REGION"
        "--platform=managed"
        "--memory=${CLOUD_RUN_MEMORY:-1Gi}"
        "--cpu=${CLOUD_RUN_CPU:-1}"
        "--max-instances=${CLOUD_RUN_MAX_INSTANCES:-10}"
        "--min-instances=${CLOUD_RUN_MIN_INSTANCES:-0}"
        "--concurrency=${CLOUD_RUN_CONCURRENCY:-80}"
        "--timeout=${CLOUD_RUN_TIMEOUT:-300}"
        "--port=8000"
    )
    
    # Add environment variables (properly quoted to prevent injection)
    deploy_cmd+=(
        "--set-env-vars=APP_ENV=production"
        "--set-env-vars=LOG_LEVEL=$LOG_LEVEL"
        "--set-env-vars=GUNICORN_LOG_LEVEL=$GUNICORN_LOG_LEVEL"
        "--set-env-vars=DATABASE_URL=$DATABASE_URL"
        "--set-env-vars=FRONTEND_URL=$FRONTEND_URL"
        "--set-env-vars=BASE_PATH=$BASE_PATH"
        "--set-env-vars=SKIP_DB_WAIT=$SKIP_DB_WAIT"
    )
    
    # Add Cloud SQL connection if specified
    if [[ -n "$CLOUD_SQL_CONNECTION_NAME" ]]; then
        deploy_cmd+=("--add-cloudsql-instances=$CLOUD_SQL_CONNECTION_NAME")
    fi
    
    # Set traffic allocation
    deploy_cmd+=("--allow-unauthenticated")
    
    # Execute deployment securely (no eval, proper quoting)
    "${deploy_cmd[@]}"
    
    # Get the service URL
    local backend_url=$(gcloud run services describe "$BACKEND_SERVICE_NAME" \
        --region="$GOOGLE_CLOUD_REGION" \
        --format="value(status.url)")
    
    log_success "Backend deployed successfully!"
    log_info "Backend URL: $backend_url"
}

deploy_frontend() {
    if [[ "$DEPLOY_FRONTEND" != "true" ]]; then
        return 0
    fi
    
    log_info "Deploying frontend to Cloud Run..."
    
    # Prepare Cloud Run deployment command using array for security
    local deploy_cmd=(
        "gcloud" "run" "deploy" "$FRONTEND_SERVICE_NAME"
        "--image=gcr.io/$GOOGLE_CLOUD_PROJECT/frontend:$FRONTEND_IMAGE_TAG"
        "--region=$GOOGLE_CLOUD_REGION"
        "--platform=managed"
        "--memory=${CLOUD_RUN_MEMORY:-1Gi}"
        "--cpu=${CLOUD_RUN_CPU:-1}"
        "--max-instances=${CLOUD_RUN_MAX_INSTANCES:-10}"
        "--min-instances=${CLOUD_RUN_MIN_INSTANCES:-0}"
        "--concurrency=${CLOUD_RUN_CONCURRENCY:-80}"
        "--timeout=${CLOUD_RUN_TIMEOUT:-300}"
        "--port=3000"
    )
    
    # Add environment variables (properly quoted to prevent injection)
    deploy_cmd+=(
        "--set-env-vars=NODE_ENV=production"
        "--set-env-vars=NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL"
        "--set-env-vars=NEXT_PUBLIC_BASE_PATH=$NEXT_PUBLIC_BASE_PATH"
        "--set-env-vars=INTERNAL_API_URL=$INTERNAL_API_URL"
    )
    
    # Set traffic allocation
    deploy_cmd+=("--allow-unauthenticated")
    
    # Execute deployment securely (no eval, proper quoting)
    "${deploy_cmd[@]}"
    
    # Get the service URL
    local frontend_url=$(gcloud run services describe "$FRONTEND_SERVICE_NAME" \
        --region="$GOOGLE_CLOUD_REGION" \
        --format="value(status.url)")
    
    log_success "Frontend deployed successfully!"
    log_info "Frontend URL: $frontend_url"
}

cleanup() {
    log_info "Cleaning up local Docker images..."
    
    if [[ "$BUILD_BACKEND" == "true" ]]; then
        docker rmi "gcr.io/$GOOGLE_CLOUD_PROJECT/backend:$BACKEND_IMAGE_TAG" 2>/dev/null || true
    fi
    
    if [[ "$BUILD_FRONTEND" == "true" ]]; then
        docker rmi "gcr.io/$GOOGLE_CLOUD_PROJECT/frontend:$FRONTEND_IMAGE_TAG" 2>/dev/null || true
    fi
}

print_final_summary() {
    echo -e "${GREEN}"
    echo "============================================================"
    echo "                 DEPLOYMENT COMPLETE!"
    echo "============================================================"
    echo -e "${NC}"
    
    if [[ "$DEPLOY_BACKEND" == "true" ]]; then
        local backend_url=$(gcloud run services describe "$BACKEND_SERVICE_NAME" \
            --region="$GOOGLE_CLOUD_REGION" \
            --format="value(status.url)" 2>/dev/null || echo "URL not available")
        echo "🚀 Backend Service: $backend_url"
        echo "   API Docs: $backend_url/docs"
    fi
    
    if [[ "$DEPLOY_FRONTEND" == "true" ]]; then
        local frontend_url=$(gcloud run services describe "$FRONTEND_SERVICE_NAME" \
            --region="$GOOGLE_CLOUD_REGION" \
            --format="value(status.url)" 2>/dev/null || echo "URL not available")
        echo "🌐 Frontend Service: $frontend_url"
    fi
    
    echo ""
    echo "📋 Next Steps:"
    echo "   • Configure custom domains in Cloud Run console (optional)"
    echo "   • Set up monitoring and alerting"
    echo "   • Update DNS records to point to your services"
    echo "   • Configure CI/CD pipeline for automatic deployments"
    echo ""
    echo "🔧 Manage your services:"
    echo "   gcloud run services list --region=$GOOGLE_CLOUD_REGION"
    echo "   gcloud run services describe $BACKEND_SERVICE_NAME --region=$GOOGLE_CLOUD_REGION"
    echo "   gcloud run services describe $FRONTEND_SERVICE_NAME --region=$GOOGLE_CLOUD_REGION"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--backend-only)
            BUILD_FRONTEND=false
            DEPLOY_FRONTEND=false
            shift
            ;;
        -f|--frontend-only)
            BUILD_BACKEND=false
            DEPLOY_BACKEND=false
            shift
            ;;
        -y|--yes)
            SKIP_CONFIRMATION=true
            shift
            ;;
        --no-build)
            BUILD_BACKEND=false
            BUILD_FRONTEND=false
            shift
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

# Main execution
main() {
    print_header
    
    load_environment
    check_prerequisites
    show_deployment_summary
    
    # Build images
    build_backend
    build_frontend
    
    # Deploy services
    deploy_backend
    deploy_frontend
    
    # Clean up
    cleanup
    
    # Show final summary
    print_final_summary
}

# Execute main function with error handling
if ! main; then
    log_error "Deployment failed!"
    exit 1
fi
