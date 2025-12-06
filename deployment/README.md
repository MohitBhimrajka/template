# Google Cloud Deployment Guide

Complete deployment solution for deploying your FastAPI + Next.js application to Google Cloud Run with PostgreSQL on Cloud SQL.

## 🚀 Quick Start

### Prerequisites

1. **Google Cloud Account** with billing enabled
2. **Google Cloud SDK** installed: [Install Guide](https://cloud.google.com/sdk/docs/install)
3. **Docker** installed and running
4. **Git** repository with your code

### One-Command Deployment

```bash
# 1. Copy and customize environment file
cp deployment/prod.example.env deployment/.env.prod
# Edit .env.prod with your settings

# 2. Set up Cloud SQL database (optional - guided setup)
./deployment/setup-cloudsql.sh

# 3. Deploy everything to Cloud Run
./deployment/gcloud-deploy.sh
```

That's it! Your application will be live on Google Cloud Run.

## 📁 Deployment Files

```
deployment/
├── README.md              # This file - deployment documentation
├── prod.example.env       # Production environment template
├── gcloud-deploy.sh       # Main deployment script
├── setup-cloudsql.sh     # Cloud SQL setup helper
└── cloudbuild.yaml       # CI/CD pipeline configuration
```

## 🗄️ Database Setup

### Option 1: Guided Cloud SQL Setup (Recommended)

```bash
./deployment/setup-cloudsql.sh
```

**Features:**
- Interactive setup with sensible defaults
- Automatic database and user creation
- Generates connection strings for your app
- Configures backups and maintenance windows

### Option 2: Manual Cloud SQL Setup

```bash
# Create Cloud SQL instance
gcloud sql instances create myapp-db \
  --database-version=POSTGRES_14 \
  --tier=db-f1-micro \
  --region=us-central1 \
  --root-password=secure-root-password

# Create database and user
gcloud sql databases create myapp_prod --instance=myapp-db
gcloud sql users create myapp_user --instance=myapp-db --password=secure-password
```

### Option 3: External Database

You can use any PostgreSQL database (AWS RDS, Azure Database, etc.). Just update the `DATABASE_URL` in your `.env.prod` file.

## ⚙️ Environment Configuration

### 1. Create Production Environment File

```bash
cp deployment/prod.example.env deployment/.env.prod
```

### 2. Customize Key Settings

**Required Settings:**
```bash
# Google Cloud Configuration
GOOGLE_CLOUD_PROJECT=your-project-id
GOOGLE_CLOUD_REGION=us-central1
BACKEND_SERVICE_NAME=your-app-backend
FRONTEND_SERVICE_NAME=your-app-frontend

# Database (from Cloud SQL setup)
DATABASE_URL=postgresql://user:pass@/dbname?host=/cloudsql/project:region:instance
CLOUD_SQL_CONNECTION_NAME=project:region:instance
```

**Optional Performance Settings:**
```bash
# Cloud Run Resources
CLOUD_RUN_MEMORY=1Gi          # 1Gi, 2Gi, 4Gi, 8Gi
CLOUD_RUN_CPU=1               # 1, 2, 4, 8 vCPUs
CLOUD_RUN_MAX_INSTANCES=10    # Auto-scaling limit
CLOUD_RUN_CONCURRENCY=80      # Requests per instance
```

## 🛠️ Deployment Scripts

### Main Deployment Script

```bash
./deployment/gcloud-deploy.sh [OPTIONS]
```

**Options:**
- `--backend-only` - Deploy only the backend service
- `--frontend-only` - Deploy only the frontend service  
- `--yes` - Skip confirmation prompts
- `--no-build` - Skip Docker image building

**Examples:**
```bash
# Deploy both services
./deployment/gcloud-deploy.sh

# Deploy only backend with auto-confirmation
./deployment/gcloud-deploy.sh --backend-only --yes

# Deploy only frontend
./deployment/gcloud-deploy.sh --frontend-only
```

### Cloud SQL Setup Script

```bash
./deployment/setup-cloudsql.sh [OPTIONS]
```

**Options:**
- `-i, --instance NAME` - Instance name
- `-d, --database NAME` - Database name
- `-u, --user NAME` - App user name
- `-p, --password PASS` - App user password
- `-r, --region REGION` - Cloud region

## 🔄 CI/CD Pipeline

### Automatic Deployments with Cloud Build

1. **Enable Cloud Build API:**
   ```bash
   gcloud services enable cloudbuild.googleapis.com
   ```

2. **Set up secrets in Secret Manager:**
   ```bash
   # Create secrets for sensitive environment variables
   echo "your-database-url" | gcloud secrets create database-url --data-file=-
   echo "your-frontend-url" | gcloud secrets create frontend-url --data-file=-
   ```

3. **Create GitHub trigger:**
   ```bash
   gcloud builds triggers create github \
     --repo-name=your-repo-name \
     --repo-owner=your-github-username \
     --branch-pattern=main \
     --build-config=deployment/cloudbuild.yaml
   ```

4. **Manual build:**
   ```bash
   gcloud builds submit --config=deployment/cloudbuild.yaml
   ```

### Pipeline Features

- **Parallel Builds:** Backend and frontend build simultaneously
- **Automatic Deployment:** Deploys to Cloud Run after successful build
- **Migration Handling:** Database migrations run automatically on startup
- **Health Checks:** Verifies deployment success
- **Rollback Support:** Easy rollback to previous versions

## 🌐 Custom Domains & HTTPS

### Set up Custom Domain

1. **Reserve external IP (optional):**
   ```bash
   gcloud compute addresses create web-static-ip --global
   ```

2. **Configure domain mapping in Cloud Run console:**
   - Go to Cloud Run → your service → "Manage Custom Domains"
   - Add your domain (e.g., `api.yourdomain.com` for backend)
   - Follow DNS verification steps

3. **Update environment variables:**
   ```bash
   # In .env.prod
   FRONTEND_URL=https://yourdomain.com
   NEXT_PUBLIC_API_URL=https://api.yourdomain.com
   ```

### SSL/TLS Certificates

Google Cloud Run automatically provides SSL certificates for:
- Cloud Run service URLs (*.run.app)
- Custom domains (after verification)

## 📊 Monitoring & Logging

### Built-in Monitoring

Google Cloud automatically provides:
- **Metrics:** Request count, latency, error rate
- **Logging:** Application and system logs
- **Error Reporting:** Automatic error detection
- **Uptime Monitoring:** Health check monitoring

### Access Logs

```bash
# View backend logs
gcloud logs tail "resource.type=cloud_run_revision AND resource.labels.service_name=your-backend"

# View frontend logs  
gcloud logs tail "resource.type=cloud_run_revision AND resource.labels.service_name=your-frontend"

# View all Cloud Run logs
gcloud logs tail "resource.type=cloud_run_revision"
```

### Set up Alerts

```bash
# Create CPU alert policy
gcloud alpha monitoring policies create --policy-from-file=monitoring/cpu-alert.yaml
```

## 💰 Cost Optimization

### Cloud Run Pricing

- **Pay per request** - No traffic = no cost
- **Free tier:** 2 million requests/month
- **Typical costs:** $0.10-$1.00/day for small apps

### Optimization Tips

1. **Right-size resources:**
   ```bash
   # Start small and scale up if needed
   CLOUD_RUN_MEMORY=512Mi
   CLOUD_RUN_CPU=1
   ```

2. **Set minimum instances to 0:**
   ```bash
   CLOUD_RUN_MIN_INSTANCES=0  # Serverless mode
   ```

3. **Use appropriate concurrency:**
   ```bash
   CLOUD_RUN_CONCURRENCY=80  # More concurrent requests per instance
   ```

4. **Monitor and optimize database:**
   ```bash
   # Start with smallest viable tier
   gcloud sql instances patch myapp-db --tier=db-f1-micro
   ```

## 🔧 Troubleshooting

### Common Issues

**1. Build Failures**
```bash
# Check build logs
gcloud builds log $(gcloud builds list --limit=1 --format="value(id)")

# Common fixes:
# - Ensure Dockerfile exists and is valid
# - Check Docker image platform (use --platform=linux/amd64)
# - Verify environment variables are set correctly
```

**2. Deployment Failures**
```bash
# Check Cloud Run service logs
gcloud run services logs read your-backend --region=us-central1

# Common fixes:
# - Check service account permissions
# - Verify environment variables
# - Ensure database is accessible
```

**3. Database Connection Issues**
```bash
# Test Cloud SQL connection
gcloud sql connect myapp-db --user=myapp_user --database=myapp_prod

# Common fixes:
# - Check Cloud SQL instance is running
# - Verify connection name format: project:region:instance
# - Ensure Cloud Run service account has Cloud SQL Client role
```

**4. Frontend/Backend Communication**
```bash
# Check CORS configuration
# Verify API URLs are correct
# Ensure both services are deployed and accessible
```

### Debug Mode

Enable detailed logging for troubleshooting:

```bash
# In .env.prod
LOG_LEVEL=DEBUG
GUNICORN_LOG_LEVEL=debug
```

### Health Checks

Test your deployment:

```bash
# Backend health check
curl https://your-backend-service-url/api/health

# Frontend accessibility
curl https://your-frontend-service-url
```

## 🔐 Security Best Practices

### Environment Variables
- ✅ Store secrets in Secret Manager
- ✅ Use IAM for service-to-service authentication  
- ❌ Never commit `.env.prod` to version control

### Network Security
- Cloud Run services are HTTPS-only by default
- Use VPC connectors for private database access
- Configure firewalls for additional security

### Database Security
- Use strong passwords (generated by setup script)
- Enable automated backups
- Restrict network access to Cloud Run services only

## 📞 Support

### Getting Help

1. **Check deployment logs:**
   ```bash
   gcloud run services logs read your-service --region=us-central1
   ```

2. **Verify configuration:**
   ```bash
   gcloud run services describe your-service --region=us-central1
   ```

3. **Google Cloud Support:**
   - [Cloud Run Documentation](https://cloud.google.com/run/docs)
   - [Cloud SQL Documentation](https://cloud.google.com/sql/docs)
   - [Community Support](https://cloud.google.com/support/community)

### Useful Commands

```bash
# List all services
gcloud run services list

# Get service URL
gcloud run services describe SERVICE_NAME --region=REGION --format="value(status.url)"

# Scale service
gcloud run services update SERVICE_NAME --region=REGION --max-instances=20

# View service metrics
gcloud run services metrics list --service=SERVICE_NAME --region=REGION
```

---

## 🎯 Next Steps

After successful deployment:

1. **Set up monitoring alerts**
2. **Configure custom domains**  
3. **Set up CI/CD pipeline**
4. **Enable Cloud SQL backups**
5. **Configure load testing**
6. **Set up staging environment**

Your application is now running on Google Cloud Run with enterprise-grade reliability, security, and scalability! 🚀
