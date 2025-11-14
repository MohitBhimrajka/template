#!/usr/bin/env python3
"""
Database readiness checker script.
Waits for PostgreSQL to be ready before proceeding with migrations.
"""

import os
import sys
import time
import logging
import psycopg2
from psycopg2 import OperationalError

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def check_db_connection():
    """
    Check if PostgreSQL is ready to accept connections.
    Returns True if connection is successful, False otherwise.
    """
    try:
        # Get database connection details from environment
        db_host = os.getenv("POSTGRES_HOST", "postgres")
        db_port = os.getenv("POSTGRES_PORT", "5432")
        db_name = os.getenv("POSTGRES_DB", "app_db")
        db_user = os.getenv("POSTGRES_USER", "user")
        db_password = os.getenv("POSTGRES_PASSWORD", "password")
        
        # Attempt to connect
        conn = psycopg2.connect(
            host=db_host,
            port=db_port,
            database=db_name,
            user=db_user,
            password=db_password,
            connect_timeout=5
        )
        conn.close()
        logger.info("✅ Database connection successful!")
        return True
        
    except OperationalError as e:
        logger.debug(f"Database not ready: {e}")
        return False
    except Exception as e:
        logger.error(f"Unexpected error checking database: {e}")
        return False

def wait_for_database(max_retries=30, delay=2):
    """
    Wait for PostgreSQL to be ready with exponential backoff.
    
    Args:
        max_retries: Maximum number of retry attempts
        delay: Initial delay between retries (seconds)
    """
    logger.info("🔍 Waiting for PostgreSQL to be ready...")
    
    for attempt in range(max_retries):
        if check_db_connection():
            logger.info(f"🎉 PostgreSQL is ready! (attempt {attempt + 1})")
            return True
            
        if attempt < max_retries - 1:
            wait_time = min(delay * (1.5 ** attempt), 30)  # Exponential backoff, max 30s
            logger.info(f"⏳ PostgreSQL not ready yet. Retrying in {wait_time:.1f}s... (attempt {attempt + 1}/{max_retries})")
            time.sleep(wait_time)
    
    logger.error(f"❌ Failed to connect to PostgreSQL after {max_retries} attempts")
    return False

if __name__ == "__main__":
    # Check if we should skip the wait (for testing purposes)
    if os.getenv("SKIP_DB_WAIT", "").lower() == "true":
        logger.info("⏭️  Skipping database wait (SKIP_DB_WAIT=true)")
        sys.exit(0)
    
    # Wait for database
    if wait_for_database():
        logger.info("✅ Database is ready, proceeding with application startup...")
        sys.exit(0)
    else:
        logger.error("❌ Database is not available, exiting...")
        sys.exit(1)
