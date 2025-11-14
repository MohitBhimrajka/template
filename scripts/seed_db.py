# scripts/seed_db.py
import os
import sys

from sqlalchemy.orm import sessionmaker

# Add the project root to the Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.database import engine
from app.models.item import Item

# Create a new session for this script
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
db = SessionLocal()


def seed_data():
    """Populates the database with initial data."""
    try:
        print("Seeding initial data...")

        # Check if items already exist
        if db.query(Item).count() == 0:
            print("Adding sample items...")
            item1 = Item(
                name="First Sample Item",
                description="This is a test item from the seeder.",
            )
            item2 = Item(
                name="Second Sample Item",
                description="Another test item for demonstration.",
            )
            db.add_all([item1, item2])
            db.commit()
            print("Sample items added.")
        else:
            print("Items table is not empty, skipping seeding.")

        print("✅ Data seeding complete.")

    except Exception as e:
        print(f"❌ An error occurred during data seeding: {e}")
        db.rollback()
    finally:
        db.close()


if __name__ == "__main__":
    print("--- Starting Database Seeding ---")
    seed_data()
