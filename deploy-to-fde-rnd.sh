#!/bin/bash

# ===================================================================
#      ONE-COMMAND DEPLOYMENT TO fde-rnd PROJECT
# -------------------------------------------------------------------
#  Complete deployment script - sets up environment and deploys
# ===================================================================

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}"
echo "============================================================"
echo "    DEPLOYING TO GOOGLE CLOUD PROJECT: fde-rnd"
echo "============================================================"
echo -e "${NC}"

# Step 1: Setup environment
echo -e "${YELLOW}[STEP 1/4]${NC} Setting up environment..."
./deployment/setup-env-fde-rnd.sh

# Step 2: Authenticate (if needed)
echo -e "${YELLOW}[STEP 2/4]${NC} Checking Google Cloud authentication..."
if ! gcloud config get-value project &>/dev/null || [ "$(gcloud config get-value project)" != "fde-rnd" ]; then
    echo "Setting up Google Cloud authentication..."
    gcloud config set project fde-rnd
    echo "✅ Project set to fde-rnd"
else
    echo "✅ Already authenticated and configured for fde-rnd"
fi

# Step 3: Setup Cloud SQL (optional)
echo -e "${YELLOW}[STEP 3/4]${NC} Database setup..."
read -p "Do you want to set up Cloud SQL database? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./deployment/setup-cloudsql.sh
else
    echo "⚠️  Skipping Cloud SQL setup. You can run ./deployment/setup-cloudsql.sh later."
fi

# Step 4: Deploy to Cloud Run
echo -e "${YELLOW}[STEP 4/4]${NC} Deploying to Google Cloud Run..."
./deployment/gcloud-deploy.sh --yes

echo -e "${GREEN}"
echo "============================================================"
echo "    DEPLOYMENT TO fde-rnd COMPLETE!"
echo "============================================================"
echo -e "${NC}"
echo ""
echo "🎉 Your application is now live on Google Cloud Run!"
echo ""
echo "📋 What was deployed:"
echo "   • Backend API (FastAPI) with automatic database migrations"
echo "   • Frontend web app (Next.js) with production optimizations"
echo "   • Automatic HTTPS and SSL certificates"
echo "   • Auto-scaling serverless infrastructure"
echo ""
echo "🔧 Manage your deployment:"
echo "   gcloud run services list --region=us-central1"
echo "   gcloud run services logs read template-backend --region=us-central1"
echo ""
echo "💰 Expected costs: ~$0.10-1.00/day + ~$7-15/month for database"
