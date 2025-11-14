# gunicorn/prod.py
"""Gunicorn *production* config file"""

import multiprocessing
import os

# FastAPI ASGI application path
wsgi_app = "app.main:app"

# Logging
loglevel = os.getenv("GUNICORN_LOG_LEVEL", "info")
accesslog = errorlog = "-"  # Log to stdout/stderr for Docker
capture_output = True

# Concurrency and Workers
# Use the WEB_CONCURRENCY env var if set, otherwise calculate based on CPU
workers = 1  # int(os.getenv("WEB_CONCURRENCY", multiprocessing.cpu_count() * 2 + 1))
worker_class = "uvicorn.workers.UvicornWorker"
worker_connections = int(os.getenv("WORKER_CONNECTIONS", "1000"))
timeout = int(os.getenv("GUNICORN_TIMEOUT", "120"))

# Server socket
bind = f"0.0.0.0:{os.getenv('PORT', '8000')}"

# Production settings (no reload, no daemon)
reload = False
daemon = False
