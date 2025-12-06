#!/usr/bin/env python3
"""
Production-safe database migration utilities.

This script provides safe migration management tools that can be used
in both development and production environments.
"""
import os
import sys
import subprocess
import argparse
from datetime import datetime

# Add the project root to the Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def run_command(command, description, capture_output=True):
    """Run a command safely and return the result."""
    print(f"[INFO] {description}")
    print(f"[DEBUG] Command: {command}")
    
    try:
        result = subprocess.run(
            command,
            shell=True,
            check=True,
            capture_output=capture_output,
            text=True,
            timeout=300  # 5 minute timeout
        )
        
        if capture_output and result.stdout.strip():
            print(f"[OUTPUT]\n{result.stdout}")
            
        return result.stdout if capture_output else ""
        
    except subprocess.TimeoutExpired:
        print(f"[ERROR] {description} timed out after 5 minutes")
        return None
        
    except subprocess.CalledProcessError as e:
        print(f"[ERROR] {description} failed with exit code {e.returncode}")
        if capture_output:
            if e.stdout:
                print(f"[STDOUT] {e.stdout}")
            if e.stderr:
                print(f"[STDERR] {e.stderr}")
        return None


def show_current_revision():
    """Show the current database migration revision."""
    print("📍 CURRENT MIGRATION STATUS")
    print("=" * 50)
    
    output = run_command("alembic current -v", "Getting current migration revision")
    if output is None:
        print("❌ Could not retrieve current revision")
        return False
    
    if not output.strip():
        print("⚠️  No migrations have been applied yet")
    
    return True


def show_migration_history():
    """Show the migration history."""
    print("📚 MIGRATION HISTORY")
    print("=" * 50)
    
    output = run_command("alembic history -v", "Getting migration history")
    if output is None:
        print("❌ Could not retrieve migration history")
        return False
    
    return True


def check_pending_migrations():
    """Check for pending migrations that haven't been applied."""
    print("🔍 CHECKING FOR PENDING MIGRATIONS")
    print("=" * 50)
    
    # Get current revision
    current_output = run_command("alembic current", "Getting current revision")
    if current_output is None:
        return False
    
    # Get heads (latest migrations)
    heads_output = run_command("alembic heads", "Getting migration heads")
    if heads_output is None:
        return False
    
    current_rev = current_output.strip()
    heads = heads_output.strip()
    
    if not current_rev:
        print("⚠️  No migrations applied yet - all migrations are pending")
        return True
    
    # Extract the revision ID from current output (handles format like "abc123def (head)")
    current_revision_id = current_rev.split()[0] if current_rev else ""
    
    # Get list of head revision IDs
    head_revisions = [rev.strip() for rev in heads.split('\n') if rev.strip()]
    
    if current_revision_id in head_revisions:
        print("✅ Database is up to date - no pending migrations")
    else:
        print("📋 Pending migrations found - database needs updating")
        print("Run 'alembic upgrade head' to apply pending migrations")
    
    return True


def validate_migration_files():
    """Validate migration files for common issues."""
    print("🔍 VALIDATING MIGRATION FILES")
    print("=" * 50)
    
    # Check for migration file issues
    alembic_dir = "alembic/versions"
    if not os.path.exists(alembic_dir):
        print("❌ Alembic versions directory not found")
        return False
    
    migration_files = [f for f in os.listdir(alembic_dir) if f.endswith('.py')]
    
    if not migration_files:
        print("⚠️  No migration files found")
        return True
    
    print(f"📁 Found {len(migration_files)} migration files")
    
    # Basic validation
    for filename in migration_files:
        filepath = os.path.join(alembic_dir, filename)
        try:
            with open(filepath, 'r') as f:
                content = f.read()
                
            # Check for common issues
            if 'def upgrade(' not in content:
                print(f"⚠️  {filename}: Missing upgrade function")
            
            if 'def downgrade(' not in content:
                print(f"⚠️  {filename}: Missing downgrade function")
                
        except Exception as e:
            print(f"❌ Error reading {filename}: {e}")
    
    print("✅ Migration file validation completed")
    return True


def show_database_info():
    """Show database connection information."""
    print("🗄️  DATABASE CONNECTION INFO")
    print("=" * 50)
    
    database_url = os.getenv("DATABASE_URL", "Not set")
    app_env = os.getenv("APP_ENV", "Not set")
    
    print(f"Environment: {app_env}")
    print(f"Database URL: {database_url[:50]}..." if len(database_url) > 50 else f"Database URL: {database_url}")
    
    # Additional connection details
    postgres_host = os.getenv("POSTGRES_HOST", "Not set")
    postgres_db = os.getenv("POSTGRES_DB", "Not set")
    postgres_user = os.getenv("POSTGRES_USER", "Not set")
    
    print(f"Host: {postgres_host}")
    print(f"Database: {postgres_db}")
    print(f"User: {postgres_user}")
    

def apply_migrations():
    """Apply pending migrations safely."""
    print("🚀 APPLYING MIGRATIONS")
    print("=" * 50)
    
    app_env = os.getenv("APP_ENV", "development")
    
    # Show what we're about to do
    print(f"Environment: {app_env}")
    
    if app_env == "production":
        print("⚠️  PRODUCTION ENVIRONMENT DETECTED")
        print("This will apply migrations to the production database!")
        
        response = input("Type 'APPLY MIGRATIONS' to continue: ").strip()
        if response != "APPLY MIGRATIONS":
            print("❌ Confirmation failed. Aborting.")
            return False
    
    # Apply migrations
    result = run_command("alembic upgrade head", "Applying migrations", capture_output=False)
    
    if result is not None:
        print("✅ Migrations applied successfully")
        show_current_revision()
        return True
    else:
        print("❌ Migration failed")
        return False


def main():
    parser = argparse.ArgumentParser(description="Database migration utilities")
    parser.add_argument("command", choices=[
        "status", "current", "history", "pending", "validate", "info", "apply"
    ], help="Command to execute")
    
    args = parser.parse_args()
    
    print(f"🔧 MIGRATION UTILITIES - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)
    
    success = True
    
    if args.command == "status" or args.command == "current":
        success = show_current_revision()
    elif args.command == "history":
        success = show_migration_history()
    elif args.command == "pending":
        success = check_pending_migrations()
    elif args.command == "validate":
        success = validate_migration_files()
    elif args.command == "info":
        show_database_info()
    elif args.command == "apply":
        success = apply_migrations()
    
    print("\n" + "=" * 60)
    if success:
        print("✅ Operation completed successfully")
    else:
        print("❌ Operation failed")
        sys.exit(1)


if __name__ == "__main__":
    main()
