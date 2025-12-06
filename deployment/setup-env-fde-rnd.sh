#!/bin/bash

# ===================================================================
#      QUICK ENVIRONMENT SETUP FOR fde-rnd PROJECT
# -------------------------------------------------------------------
#  Creates .env.prod file with correct configuration for testing
# ===================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env.prod"

echo "🔧 Setting up environment for fde-rnd project..."

cat > "$ENV_FILE" << 'EOF'
# ===================================================================
#      PRODUCTION ENVIRONMENT CONFIGURATION - fde-rnd PROJECT
# ===================================================================

# Google Cloud Project Configuration
GOOGLE_CLOUD_PROJECT=fde-rnd
GOOGLE_CLOUD_REGION=us-central1
BACKEND_SERVICE_NAME=template-backend
FRONTEND_SERVICE_NAME=template-frontend

# Application Settings
APP_ENV=production
BASE_PATH=

# Backend Configuration (URLs will be updated after deployment)
FRONTEND_URL=https://template-frontend-abc123-uc.a.run.app
PORT=8000
INTERNAL_IP=0.0.0.0

# Frontend Configuration (URLs will be updated after deployment)
NEXT_PUBLIC_API_URL=https://template-backend-abc123-uc.a.run.app
NEXT_PUBLIC_BASE_PATH=
INTERNAL_API_URL=https://template-backend-abc123-uc.a.run.app

# Logging
LOG_LEVEL=INFO
GUNICORN_LOG_LEVEL=info

# Database Configuration (setup Cloud SQL first with setup-cloudsql.sh)
CLOUD_SQL_CONNECTION_NAME=fde-rnd:us-central1:template-db
POSTGRES_USER=template_user
POSTGRES_PASSWORD=SecurePass123!
POSTGRES_DB=template_prod
POSTGRES_HOST=/cloudsql/fde-rnd:us-central1:template-db
POSTGRES_PORT=5432
DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@/${POSTGRES_DB}?host=/cloudsql/${CLOUD_SQL_CONNECTION_NAME}
SKIP_DB_WAIT=false

# Production Server Configuration
WORKER_CONNECTIONS=1000
GUNICORN_TIMEOUT=300

# Cloud Run Configuration
CLOUD_RUN_MEMORY=1Gi
CLOUD_RUN_CPU=1
CLOUD_RUN_MAX_INSTANCES=10
CLOUD_RUN_MIN_INSTANCES=0
CLOUD_RUN_TIMEOUT=300
CLOUD_RUN_CONCURRENCY=80
CLOUD_RUN_ALLOW_UNAUTHENTICATED=true

# Deployment Configuration
DOCKER_REGISTRY=gcr.io
BACKEND_IMAGE_TAG=latest
FRONTEND_IMAGE_TAG=latest
BUILD_TIMEOUT=1200
REQUIRE_DEPLOYMENT_CONFIRMATION=false
EOF

echo "✅ Environment file created at: $ENV_FILE"
echo ""
echo "🚀 Next steps:"
echo "   1. Run: gcloud auth login"
echo "   2. Run: gcloud config set project fde-rnd"
echo "   3. Run: ./deployment/setup-cloudsql.sh (optional - sets up database)"
echo "   4. Run: ./deployment/gcloud-deploy.sh (deploys everything)"
echo ""
echo "🧪 To test locally first:"
echo "   ./deployment/test-local.sh --backend-only"
