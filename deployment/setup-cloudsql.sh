#!/bin/bash

# ===================================================================
#      GOOGLE CLOUD SQL SETUP SCRIPT
# -------------------------------------------------------------------
#  Creates and configures a PostgreSQL instance on Google Cloud SQL
#  for use with your application
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
DEPLOYMENT_ENV_FILE="${SCRIPT_DIR}/.env.prod"

# Default values
INSTANCE_NAME=""
DATABASE_NAME=""
ROOT_PASSWORD=""
APP_USER=""
APP_PASSWORD=""
REGION="us-central1"
TIER="db-f1-micro"
STORAGE_SIZE="10GB"
PROJECT_ID=""

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
    echo "           GOOGLE CLOUD SQL SETUP SCRIPT"
    echo "============================================================"
    echo -e "${NC}"
}

print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Set up PostgreSQL instance on Google Cloud SQL"
    echo ""
    echo "Options:"
    echo "  -i, --instance NAME     Cloud SQL instance name"
    echo "  -d, --database NAME     Database name to create"
    echo "  -u, --user NAME         Application user name"
    echo "  -p, --password PASS     Application user password"
    echo "  -r, --region REGION     Cloud SQL region (default: us-central1)"
    echo "  -t, --tier TIER         Instance tier (default: db-f1-micro)"
    echo "  -s, --storage SIZE      Storage size (default: 10GB)"
    echo "  --project PROJECT       Google Cloud project ID"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --instance myapp-db --database myapp_prod --user myapp_user"
    echo "  $0 -i myapp-db -d myapp_prod -u myapp_user -p mysecretpass"
}

load_environment_if_exists() {
    if [[ -f "$DEPLOYMENT_ENV_FILE" ]]; then
        log_info "Loading configuration from $DEPLOYMENT_ENV_FILE"
        set -a
        source "$DEPLOYMENT_ENV_FILE"
        set +a
        
        # Use values from environment file if not provided via CLI
        PROJECT_ID=${PROJECT_ID:-$GOOGLE_CLOUD_PROJECT}
        REGION=${REGION:-$GOOGLE_CLOUD_REGION}
        INSTANCE_NAME=${INSTANCE_NAME:-${BACKEND_SERVICE_NAME}-db}
        DATABASE_NAME=${DATABASE_NAME:-$POSTGRES_DB}
        APP_USER=${APP_USER:-$POSTGRES_USER}
        APP_PASSWORD=${APP_PASSWORD:-$POSTGRES_PASSWORD}
    fi
}

prompt_for_missing_values() {
    # Project ID
    if [[ -z "$PROJECT_ID" ]]; then
        read -p "Enter Google Cloud Project ID: " PROJECT_ID
    fi
    
    # Instance name
    if [[ -z "$INSTANCE_NAME" ]]; then
        read -p "Enter Cloud SQL instance name: " INSTANCE_NAME
    fi
    
    # Database name
    if [[ -z "$DATABASE_NAME" ]]; then
        read -p "Enter database name to create: " DATABASE_NAME
    fi
    
    # App user
    if [[ -z "$APP_USER" ]]; then
        read -p "Enter application user name: " APP_USER
    fi
    
    # App password
    if [[ -z "$APP_PASSWORD" ]]; then
        read -s -p "Enter application user password: " APP_PASSWORD
        echo
    fi
    
    # Root password
    if [[ -z "$ROOT_PASSWORD" ]]; then
        log_warning "Generating secure root password..."
        ROOT_PASSWORD=$(openssl rand -base64 32)
        log_info "Generated root password (save this securely): $ROOT_PASSWORD"
    fi
}

validate_inputs() {
    local errors=0
    
    if [[ -z "$PROJECT_ID" ]]; then
        log_error "Project ID is required"
        errors=$((errors + 1))
    fi
    
    if [[ -z "$INSTANCE_NAME" ]]; then
        log_error "Instance name is required"
        errors=$((errors + 1))
    fi
    
    if [[ -z "$DATABASE_NAME" ]]; then
        log_error "Database name is required"
        errors=$((errors + 1))
    fi
    
    if [[ -z "$APP_USER" ]]; then
        log_error "Application user name is required"
        errors=$((errors + 1))
    fi
    
    if [[ -z "$APP_PASSWORD" ]]; then
        log_error "Application user password is required"
        errors=$((errors + 1))
    fi
    
    if [[ $errors -gt 0 ]]; then
        exit 1
    fi
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if gcloud is installed
    if ! command -v gcloud &> /dev/null; then
        log_error "Google Cloud SDK (gcloud) is not installed"
        log_info "Install from: https://cloud.google.com/sdk/docs/install"
        exit 1
    fi
    
    # Check gcloud authentication
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -1 &> /dev/null; then
        log_error "No active gcloud authentication found"
        log_info "Run: gcloud auth login"
        exit 1
    fi
    
    # Set the project
    log_info "Setting Google Cloud project to: $PROJECT_ID"
    gcloud config set project "$PROJECT_ID"
    
    # Enable required APIs
    log_info "Enabling Cloud SQL Admin API..."
    gcloud services enable sqladmin.googleapis.com
    
    log_success "Prerequisites check completed"
}

show_setup_summary() {
    echo -e "${YELLOW}"
    echo "============================================================"
    echo "                 CLOUD SQL SETUP SUMMARY"
    echo "============================================================"
    echo -e "${NC}"
    echo "Project ID:       $PROJECT_ID"
    echo "Instance Name:    $INSTANCE_NAME"
    echo "Region:           $REGION"
    echo "Instance Tier:    $TIER"
    echo "Storage Size:     $STORAGE_SIZE"
    echo "Database Name:    $DATABASE_NAME"
    echo "App User:         $APP_USER"
    echo ""
    echo "Connection Name:  $PROJECT_ID:$REGION:$INSTANCE_NAME"
    echo ""
    
    read -p "Do you want to proceed with Cloud SQL setup? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Setup cancelled"
        exit 0
    fi
}

create_sql_instance() {
    log_info "Creating Cloud SQL instance: $INSTANCE_NAME"
    
    # Check if instance already exists
    if gcloud sql instances describe "$INSTANCE_NAME" --project="$PROJECT_ID" &> /dev/null; then
        log_warning "Instance $INSTANCE_NAME already exists, skipping creation"
        return 0
    fi
    
    # Create the instance
    gcloud sql instances create "$INSTANCE_NAME" \
        --database-version=POSTGRES_14 \
        --tier="$TIER" \
        --storage-size="$STORAGE_SIZE" \
        --storage-type=SSD \
        --region="$REGION" \
        --root-password="$ROOT_PASSWORD" \
        --storage-auto-increase \
        --backup-start-time=03:00 \
        --maintenance-release-channel=production \
        --maintenance-window-day=SUN \
        --maintenance-window-hour=04 \
        --project="$PROJECT_ID"
    
    log_success "Cloud SQL instance created successfully"
}

create_database() {
    log_info "Creating database: $DATABASE_NAME"
    
    # Check if database already exists
    if gcloud sql databases describe "$DATABASE_NAME" --instance="$INSTANCE_NAME" --project="$PROJECT_ID" &> /dev/null; then
        log_warning "Database $DATABASE_NAME already exists, skipping creation"
        return 0
    fi
    
    # Create the database
    gcloud sql databases create "$DATABASE_NAME" \
        --instance="$INSTANCE_NAME" \
        --project="$PROJECT_ID"
    
    log_success "Database created successfully"
}

create_app_user() {
    log_info "Creating application user: $APP_USER"
    
    # Check if user already exists
    if gcloud sql users describe "$APP_USER" --instance="$INSTANCE_NAME" --project="$PROJECT_ID" &> /dev/null; then
        log_warning "User $APP_USER already exists, updating password"
        
        # Update password for existing user
        gcloud sql users set-password "$APP_USER" \
            --instance="$INSTANCE_NAME" \
            --password="$APP_PASSWORD" \
            --project="$PROJECT_ID"
    else
        # Create new user
        gcloud sql users create "$APP_USER" \
            --instance="$INSTANCE_NAME" \
            --password="$APP_PASSWORD" \
            --project="$PROJECT_ID"
    fi
    
    log_success "Application user configured successfully"
}

generate_connection_info() {
    local connection_name="$PROJECT_ID:$REGION:$INSTANCE_NAME"
    local instance_ip=$(gcloud sql instances describe "$INSTANCE_NAME" --project="$PROJECT_ID" --format="value(ipAddresses[0].ipAddress)")
    
    echo -e "${GREEN}"
    echo "============================================================"
    echo "                 SETUP COMPLETE!"
    echo "============================================================"
    echo -e "${NC}"
    echo ""
    echo "📋 Connection Information:"
    echo "   Instance Name:      $INSTANCE_NAME"
    echo "   Connection Name:    $connection_name"
    echo "   Instance IP:        $instance_ip"
    echo "   Database:           $DATABASE_NAME"
    echo "   Username:           $APP_USER"
    echo "   Password:           $APP_PASSWORD"
    echo "   Root Password:      $ROOT_PASSWORD"
    echo ""
    echo "🔧 Environment Variables for .env.prod:"
    echo "   CLOUD_SQL_CONNECTION_NAME=$connection_name"
    echo "   POSTGRES_USER=$APP_USER"
    echo "   POSTGRES_PASSWORD=$APP_PASSWORD"
    echo "   POSTGRES_DB=$DATABASE_NAME"
    echo "   POSTGRES_HOST=/cloudsql/$connection_name"
    echo "   POSTGRES_PORT=5432"
    echo ""
    echo "   DATABASE_URL=postgresql://$APP_USER:$APP_PASSWORD@/$DATABASE_NAME?host=/cloudsql/$connection_name"
    echo ""
    echo "🚀 Next Steps:"
    echo "   1. Update your .env.prod file with the above values"
    echo "   2. Deploy your application: ./deployment/gcloud-deploy.sh"
    echo "   3. Your app will automatically connect to Cloud SQL"
    echo ""
    echo "💡 Tips:"
    echo "   • Save the root password securely"
    echo "   • Monitor usage in Cloud Console"
    echo "   • Set up alerts for high CPU/memory usage"
    echo "   • Consider enabling point-in-time recovery for production"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--instance)
            INSTANCE_NAME="$2"
            shift 2
            ;;
        -d|--database)
            DATABASE_NAME="$2"
            shift 2
            ;;
        -u|--user)
            APP_USER="$2"
            shift 2
            ;;
        -p|--password)
            APP_PASSWORD="$2"
            shift 2
            ;;
        -r|--region)
            REGION="$2"
            shift 2
            ;;
        -t|--tier)
            TIER="$2"
            shift 2
            ;;
        -s|--storage)
            STORAGE_SIZE="$2"
            shift 2
            ;;
        --project)
            PROJECT_ID="$2"
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

# Main execution
main() {
    print_header
    
    load_environment_if_exists
    prompt_for_missing_values
    validate_inputs
    check_prerequisites
    show_setup_summary
    
    create_sql_instance
    create_database
    create_app_user
    
    generate_connection_info
}

# Execute main function with error handling
if ! main; then
    log_error "Cloud SQL setup failed!"
    exit 1
fi
