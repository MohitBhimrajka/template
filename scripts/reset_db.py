# scripts/reset_db.py
"""
DANGEROUS DATABASE RESET SCRIPT

⚠️  WARNING: This script DESTROYS ALL DATA in the database!
⚠️  This should ONLY be used in development environments!
⚠️  NEVER run this script in production!

This script drops the entire public schema and recreates it from scratch.
All data will be permanently lost.
"""
import os
import sys
import time

from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

# Add the project root to the Python path to allow importing 'app'
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.database import Base, engine


def check_production_safety():
    """
    Comprehensive production safety checks.
    Prevents accidental execution in production environments.
    """
    # Check environment variable
    app_env = os.getenv("APP_ENV", "").lower()
    if app_env == "production":
        print("❌ BLOCKED: This script is disabled in production environment (APP_ENV=production)")
        return False
    
    # Check for production database indicators
    database_url = os.getenv("DATABASE_URL", "")
    production_indicators = [
        "amazonaws.com",
        "rds.amazonaws.com", 
        "googleusercontent.com",
        "azure.com",
        "digitalocean.com",
        "heroku.com",
        "railway.app",
        "vercel.com",
        "planetscale.com"
    ]
    
    for indicator in production_indicators:
        if indicator in database_url:
            print(f"❌ BLOCKED: Detected production database service ({indicator}) in DATABASE_URL")
            return False
    
    # Check for production database names
    production_db_names = ["production", "prod", "live", "main"]
    postgres_db = os.getenv("POSTGRES_DB", "").lower()
    if postgres_db in production_db_names:
        print(f"❌ BLOCKED: Database name '{postgres_db}' appears to be production")
        return False
    
    return True


def interactive_confirmation():
    """
    Interactive confirmation to prevent accidental execution.
    """
    print("\n" + "="*60)
    print("⚠️  DATABASE RESET CONFIRMATION ⚠️")
    print("="*60)
    print("This will PERMANENTLY DELETE ALL DATA in the database!")
    print("Tables, data, indexes - everything will be destroyed!")
    print("="*60)
    
    database_url = os.getenv("DATABASE_URL", "Not set")
    postgres_db = os.getenv("POSTGRES_DB", "Not set")
    print(f"Target Database: {postgres_db}")
    print(f"Connection URL: {database_url[:50]}..." if len(database_url) > 50 else f"Connection URL: {database_url}")
    print("="*60)
    
    # First confirmation
    response1 = input("\nType 'DELETE ALL DATA' to confirm you want to proceed: ").strip()
    if response1 != "DELETE ALL DATA":
        print("❌ Confirmation failed. Aborting.")
        return False
    
    # Second confirmation with database name
    response2 = input(f"\nConfirm by typing the database name '{postgres_db}': ").strip()
    if response2 != postgres_db:
        print("❌ Database name confirmation failed. Aborting.")
        return False
    
    # Final countdown
    print("\n⚠️  FINAL WARNING: Starting deletion in 5 seconds...")
    print("Press Ctrl+C to abort!")
    for i in range(5, 0, -1):
        print(f"Deleting in {i}...")
        time.sleep(1)
    
    return True


def reset_database():
    """Drops and recreates all tables in the public schema."""
    print("\n🔄 Starting database reset process...")
    print("Connecting to the database...")

    try:
        # Use a transaction to ensure DDL statements are committed
        with engine.begin() as connection:
            print("🗑️  Dropping public schema (this destroys all data)...")
            # Use CASCADE to drop dependent objects
            connection.execute(text("DROP SCHEMA public CASCADE;"))
            print("🏗️  Creating new public schema...")
            connection.execute(text("CREATE SCHEMA public;"))

        print("📋 Creating all tables from SQLAlchemy metadata...")
        Base.metadata.create_all(bind=engine)

        print("\n✅ Database reset completed successfully!")
        print("🆕 Fresh database created with empty tables")
        
    except Exception as e:
        print(f"\n❌ An error occurred during database reset: {e}")
        sys.exit(1)


if __name__ == "__main__":
    print("🔧 DATABASE RESET UTILITY")
    print("=" * 50)
    
    # Production safety checks
    if not check_production_safety():
        print("\n❌ Production safety check failed. Exiting.")
        sys.exit(1)
    
    print("✅ Production safety checks passed")
    
    # Interactive confirmation
    if not interactive_confirmation():
        print("❌ User confirmation failed. Exiting safely.")
        sys.exit(1)
    
    # Perform the reset
    reset_database()
    
    print("\n🎯 Reset complete! You can now run migrations:")
    print("   alembic upgrade head")
