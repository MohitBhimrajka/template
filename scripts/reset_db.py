# scripts/reset_db.py
import os
import sys

from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

# Add the project root to the Python path to allow importing 'app'
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.database import Base, engine


def reset_database():
    """Drops and recreates all tables in the public schema."""
    print("Connecting to the database...")

    try:
        # Use a raw connection to execute DDL statements outside a transaction block
        with engine.connect() as connection:
            print("Dropping public schema...")
            # Use CASCADE to drop dependent objects
            connection.execute(text("DROP SCHEMA public CASCADE;"))
            print("Creating new public schema...")
            connection.execute(text("CREATE SCHEMA public;"))

        print("Creating all tables from SQLAlchemy metadata...")
        Base.metadata.create_all(bind=engine)

        print("✅ Database reset successfully.")
    except Exception as e:
        print(f"❌ An error occurred during database reset: {e}")


if __name__ == "__main__":
    print("--- Starting Database Reset ---")
    reset_database()
