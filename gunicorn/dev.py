"""Gunicorn *development* config file"""

import multiprocessing
import os

# FastAPI ASGI application path in the pattern MODULE_NAME:VARIABLE_NAME
wsgi_app = "app.main:app"  # Update "app" if your FastAPI instance is named differently

# The granularity of Error log outputs
loglevel = "info"

# The number of worker processes for handling requests
workers = 1  # multiprocessing.cpu_count() * 2 + 1

# The socket to bind
bind = (
    str(os.getenv("INTERNAL_IP", "0.0.0.0")) + ":8000"
)  # Defaults to 0.0.0.0 for Docker compatibility

# Restart workers when code changes (development only!)
reload = True

# Write access and error info to logs
accesslog = errorlog = "-"  # "gunicorn/logs/dev.log"

# Redirect stdout/stderr to log file
capture_output = True

# PID file so you can easily fetch process ID
pidfile = "/tmp/gunicorn_dev.pid"  # Use temp directory instead

# Daemonize the Gunicorn process (detach & enter background)
daemon = False

# Timeout for workers (increase if processing large files or long requests)
timeout = 5000

# Worker class for ASGI support with FastAPI
worker_class = "uvicorn.workers.UvicornWorker"

# Maximum number of simultaneous clients (relevant for async worker types)
worker_connections = 1000
