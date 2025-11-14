# Deployment Guide

This guide provides instructions and best practices for deploying the Full-Stack Web Template to a production environment.

## Core Principles of Production Deployment

*   **Immutable Infrastructure:** We use Docker images as immutable artifacts. The same image that is tested in staging should be deployed to production.
*   **Configuration as Code:** All environment-specific settings (database URLs, secrets, etc.) are managed via environment variables, not hardcoded in the application.
*   **Security First:** Never commit secrets to your Git repository. Use a secure secret management solution.

## Step 1: Building Production Docker Images

The provided `Dockerfile` and `frontend/Dockerfile` use multi-stage builds, which are optimized for production. To build the images, you can use `docker-compose`.

1.  **Prepare your `.env` file for production:**
    *   `LOG_LEVEL` should be `INFO`.
    *   All URLs (`FRONTEND_URL`, `NEXT_PUBLIC_API_URL`, etc.) should point to your public production domains.
    *   All secrets (`DATABASE_URL`, etc.) must be set to their production values.

2.  **Build the images:**
    ```bash
    docker-compose build
    ```

3.  **Push to a Container Registry:**
    After building, tag the images and push them to a container registry like Docker Hub, AWS ECR, or Google Artifact Registry.
    ```bash
    docker tag template_backend your-registry/backend:latest
    docker push your-registry/backend:latest

    docker tag template_frontend your-registry/frontend:latest
    docker push your-registry/frontend:latest
    ```

## Step 2: Production Infrastructure

In production, you will not use the `docker-compose.yml` directly for deployment. Instead, you will use an orchestration platform like Kubernetes, AWS ECS, or a simpler setup with a Virtual Private Server (VPS) and a reverse proxy.

### Key Components:

1.  **Managed Database:** Do not run your database in a container for production. Use a managed database service like AWS RDS, Azure Database for PostgreSQL, or Google Cloud SQL. This provides automated backups, scaling, and high availability.
2.  **Reverse Proxy (Nginx, Traefik, Caddy):** A reverse proxy is essential. It will sit in front of your services and handle:
    *   **SSL Termination:** Managing HTTPS certificates.
    *   **Routing:** Directing traffic to the correct service. For example, requests to `https://yourapp.com/app1/api/*` go to the backend container, and all other requests to `/app1/*` go to the frontend container.
    *   **Caching and Load Balancing.**

## Step 3: Secret Management

**Never use the development `.env` file in production.** Your production environment must load secrets securely.

*   **Orchestration Platforms (Kubernetes/ECS):** Use built-in secret management tools (e.g., Kubernetes Secrets, AWS Secrets Manager).
*   **VPS:** Use the hosting provider's secret management tools or inject environment variables securely during your deployment process.

## Example Reverse Proxy Configuration (Nginx)

This is a simplified example of how you might configure Nginx to route traffic based on the `BASE_PATH` of `/app1`.

```nginx
server {
    listen 443 ssl;
    server_name yourapp.com;

    # SSL configuration here...

    location /app1/api/ {
        proxy_pass http://backend_service:8000; # Points to your backend container
        proxy_set_header Host $host;
        # ... other proxy headers
    }

    location /app1/ {
        proxy_pass http://frontend_service:3000; # Points to your frontend container
        proxy_set_header Host $host;
        # ... other proxy headers
    }
}
```

This guide provides a high-level overview. The exact implementation will depend on your chosen cloud provider and infrastructure.
