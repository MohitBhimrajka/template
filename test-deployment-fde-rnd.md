# Testing Google Cloud Deployment on fde-rnd Project

## Quick Setup and Test Instructions

### Step 1: Set up Environment File

Copy and paste this into `deployment/.env.prod`:

```bash
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

# Backend Configuration
FRONTEND_URL=https://template-frontend-abc123-uc.a.run.app
PORT=8000
INTERNAL_IP=0.0.0.0

# Frontend Configuration
NEXT_PUBLIC_API_URL=https://template-backend-abc123-uc.a.run.app
NEXT_PUBLIC_BASE_PATH=
INTERNAL_API_URL=https://template-backend-abc123-uc.a.run.app

# Logging
LOG_LEVEL=INFO
GUNICORN_LOG_LEVEL=info

# Database Configuration (for testing - will setup Cloud SQL later)
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
```

### Step 2: Authenticate with Google Cloud

```bash
# Ensure you're authenticated
gcloud auth login

# Set the project
gcloud config set project fde-rnd

# Verify authentication
gcloud config list
```

### Step 3: Test Local Docker Builds (Optional but Recommended)

```bash
# Test backend Docker build only
./deployment/test-local.sh --backend-only

# This will:
# 1. Build the backend Docker image
# 2. Start it locally on port 8001
# 3. Test the /api/health endpoint
# 4. Keep it running for manual testing
```

### Step 4: Set up Cloud SQL Database (Interactive Setup)

```bash
# Run the interactive Cloud SQL setup
./deployment/setup-cloudsql.sh

# This will:
# 1. Create a PostgreSQL instance on Cloud SQL
# 2. Create the database and user
# 3. Give you the connection details to update .env.prod
```

### Step 5: Deploy to Google Cloud Run

```bash
# Single command deployment
./deployment/gcloud-deploy.sh --yes

# This will:
# 1. Build Docker images for backend and frontend
# 2. Push them to Google Container Registry
# 3. Deploy both services to Cloud Run
# 4. Set up environment variables
# 5. Configure Cloud SQL connections
# 6. Return the live URLs
```

## Expected Results

After successful deployment, you should see:

```
============================================================
                 DEPLOYMENT COMPLETE!
============================================================

🚀 Backend Service: https://template-backend-xxxxx-uc.a.run.app
   API Docs: https://template-backend-xxxxx-uc.a.run.app/docs

🌐 Frontend Service: https://template-frontend-xxxxx-uc.a.run.app

📋 Next Steps:
   • Configure custom domains in Cloud Run console (optional)
   • Set up monitoring and alerting
   • Update DNS records to point to your services
   • Configure CI/CD pipeline for automatic deployments
```

## Testing the Deployed Application

1. **Test Backend API:**
   ```bash
   curl https://template-backend-xxxxx-uc.a.run.app/api/health
   ```

2. **View API Documentation:**
   Open: `https://template-backend-xxxxx-uc.a.run.app/docs`

3. **Test Frontend:**
   Open: `https://template-frontend-xxxxx-uc.a.run.app`

4. **Test Database Connection:**
   The backend should automatically run migrations and connect to Cloud SQL

## Troubleshooting Commands

```bash
# View backend logs
gcloud run services logs read template-backend --region=us-central1

# View frontend logs  
gcloud run services logs read template-frontend --region=us-central1

# Check service status
gcloud run services list --region=us-central1

# Get service details
gcloud run services describe template-backend --region=us-central1
```

## Cost Estimate

For testing/development:
- **Cloud Run**: ~$0.10-$1.00/day (pay per request)
- **Cloud SQL**: ~$7-$15/month (db-f1-micro instance)
- **Container Registry**: ~$0.01-$0.10/month (image storage)

**Total**: ~$7-$16/month for a small development deployment

## Cleanup Commands

```bash
# Delete Cloud Run services
gcloud run services delete template-backend --region=us-central1 --quiet
gcloud run services delete template-frontend --region=us-central1 --quiet

# Delete Cloud SQL instance (careful - this deletes all data!)
gcloud sql instances delete template-db --quiet

# Delete Docker images
gcloud container images delete gcr.io/fde-rnd/backend --quiet
gcloud container images delete gcr.io/fde-rnd/frontend --quiet
```
