#!/usr/bin/env python3
"""
Cross-platform entrypoint script for the application.
Handles both development and production environments.
"""
import os
import sys
import subprocess


def run_command(command, description):
    """Run a command and handle errors."""
    print(f"[INFO] {description}")
    try:
        result = subprocess.run(command, shell=True, check=True)
        return result.returncode == 0
    except subprocess.CalledProcessError as e:
        print(f"[ERROR] {description} failed with exit code {e.returncode}")
        sys.exit(1)


def main():
    print("[INFO] Starting application...")
    
    # Wait for database to be ready
    run_command("python utils/wait_for_db.py", "Waiting for database connection")
    
    # Run database migrations
    run_command("alembic upgrade head", "Running database migrations")
    
    # Determine which gunicorn config to use based on environment
    app_env = os.getenv("APP_ENV", "development")
    
    if app_env == "production":
        print("[INFO] Starting production server...")
        command = "gunicorn -c gunicorn/prod.py app.main:app"
    else:
        print("[INFO] Starting development server...")
        command = "gunicorn -c gunicorn/dev.py app.main:app"
    
    # Execute gunicorn (replace current process)
    os.system(command)


if __name__ == "__main__":
    main()
