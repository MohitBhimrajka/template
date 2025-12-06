#!/usr/bin/env python3
"""
Cross-platform entrypoint script for the application.
Handles both development and production environments with robust error handling.
"""
import os
import sys
import subprocess
import time
import signal


def run_command_with_timeout(command, description, timeout_seconds=300):
    """Run a command with timeout and enhanced error handling."""
    print(f"[INFO] {description}")
    print(f"[DEBUG] Executing: {command}")
    
    try:
        result = subprocess.run(
            command, 
            shell=True, 
            check=True, 
            capture_output=True, 
            text=True, 
            timeout=timeout_seconds
        )
        
        # Log output for debugging
        if result.stdout.strip():
            print(f"[DEBUG] Output: {result.stdout.strip()}")
        
        print(f"[SUCCESS] {description} completed successfully")
        return True
        
    except subprocess.TimeoutExpired:
        print(f"[ERROR] {description} timed out after {timeout_seconds} seconds")
        print(f"[ERROR] This may indicate a database connectivity issue or long-running migration")
        sys.exit(1)
        
    except subprocess.CalledProcessError as e:
        print(f"[ERROR] {description} failed with exit code {e.returncode}")
        if e.stdout:
            print(f"[ERROR] stdout: {e.stdout}")
        if e.stderr:
            print(f"[ERROR] stderr: {e.stderr}")
        print(f"[ERROR] Command was: {command}")
        sys.exit(1)
        
    except Exception as e:
        print(f"[ERROR] Unexpected error during {description}: {e}")
        sys.exit(1)


def check_migration_status():
    """Check current migration status before running migrations."""
    print("[INFO] Checking current migration status...")
    try:
        result = subprocess.run(
            "alembic current", 
            shell=True, 
            capture_output=True, 
            text=True, 
            timeout=30
        )
        if result.returncode == 0 and result.stdout.strip():
            print(f"[INFO] Current migration: {result.stdout.strip()}")
        else:
            print("[INFO] No migrations found or database not initialized")
    except Exception as e:
        print(f"[WARNING] Could not check migration status: {e}")


def run_migrations_safely():
    """Run database migrations with enhanced safety and logging."""
    app_env = os.getenv("APP_ENV", "development")
    
    # Check migration status first
    check_migration_status()
    
    # Set appropriate timeout based on environment
    timeout = 600 if app_env == "production" else 300  # 10 min for prod, 5 min for dev
    
    print(f"[INFO] Running database migrations (timeout: {timeout}s)")
    print("[INFO] This applies new migrations only - existing data is preserved")
    
    success = run_command_with_timeout(
        "alembic upgrade head", 
        "Applying database migrations",
        timeout
    )
    
    if success:
        print("[SUCCESS] All migrations completed successfully")
        # Show final migration status
        check_migration_status()


def main():
    app_env = os.getenv("APP_ENV", "development")
    print(f"[INFO] Starting application in {app_env} mode...")
    
    # Wait for database to be ready
    run_command_with_timeout(
        "python utils/wait_for_db.py", 
        "Waiting for database connection",
        120  # 2 minutes timeout for DB connection
    )
    
    # Run database migrations safely
    run_migrations_safely()
    
    # Determine which gunicorn config to use based on environment
    if app_env == "production":
        print("[INFO] Starting production server with Gunicorn...")
        command = "gunicorn -c gunicorn/prod.py app.main:app"
    else:
        print("[INFO] Starting development server with Gunicorn...")
        command = "gunicorn -c gunicorn/dev.py app.main:app"
    
    print(f"[INFO] Server command: {command}")
    
    # Execute gunicorn (replace current process)
    # Use exec to properly handle signals in Docker
    os.execvp("gunicorn", command.split())


if __name__ == "__main__":
    main()
