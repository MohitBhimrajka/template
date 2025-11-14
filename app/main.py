# app/main.py
import logging
import os
from datetime import datetime, timezone

import geoip2.database
from fastapi import APIRouter, Depends, FastAPI, Header, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy.orm import Session

# Import models and schemas
from . import models, schemas
# Import the database dependency
from .core.database import get_db
# Import the logging setup function
from .core.logging_config import setup_logging
# Import the authentication dependency (simplified - no auth required)
from .security import get_current_user, verify_access

# --- Logger Initialization ---
# Get a logger for this module
log = logging.getLogger(__name__)

# --- Database Integration Completed ---
# The mock_db has been replaced with a real PostgreSQL database
# All data is now managed through SQLAlchemy ORM models
# To use Geofencing, you must download the free GeoLite2-Country.mmdb database from MaxMind's website
# and place it in the root directory of your project. Run: pip install geoip2
try:
    geoip_reader = geoip2.database.Reader("/app/app/GeoLite2-Country.mmdb")
except FileNotFoundError:
    geoip_reader = None
    log.warning("GeoLite2-Country.mmdb not found. Geofencing will default to 'US'.")


# --- Pydantic Models for Request Bodies ---
class PurchaseOrder(BaseModel):
    amount: int


class FileUpload(BaseModel):
    size: int


# --- App & Router Initialization ---
# Create the FastAPI app instance
app = FastAPI(title="Web Template API")


@app.on_event("startup")
async def startup_event():
    """
    Actions to take on application startup.
    """
    setup_logging()
    log.info("Application startup complete.")


base_path = os.getenv("BASE_PATH", "")
# The global 'verify_access' dependency is applied here. It will protect every
# endpoint on this router according to the rules in this file.
api_router = APIRouter(prefix=f"{base_path}/api", dependencies=[Depends(verify_access)])

# Add the CORS middleware to the main FastAPI app instance.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, restrict this to your frontend's domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- SIMPLE ENDPOINTS (Protected Automatically) ---
# These endpoints require no special code because their rules are simple
# and are handled by the global 'verify_access' dependency.


@api_router.get("/health", tags=["Health"])
def read_health():
    """Liveness probe. Public via public.map.json."""
    return {"status": "ok"}


@api_router.get("/test", tags=["Simple Scenarios"])
def read_test_data():
    """Test endpoint - no authentication required."""
    return {"message": "Hello, World! No authentication required."}


@api_router.get("/admin/dashboard", tags=["Simple Scenarios"])
def get_admin_dashboard():
    """Admin dashboard - no authentication required in template."""
    return {
        "message": "Welcome to the admin dashboard! Authentication can be added as needed."
    }


# --- NEW DATABASE-DRIVEN ENDPOINTS ---


@api_router.post("/items/", response_model=schemas.Item, tags=["Items"])
def create_item(item: schemas.ItemCreate, db: Session = Depends(get_db)):
    """
    Create a new item in the database.
    This endpoint requires any authenticated user.
    """
    db_item = models.Item(name=item.name, description=item.description)
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item


@api_router.get("/items/", response_model=list[schemas.Item], tags=["Items"])
def list_items(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """
    List all items from the database.
    This endpoint requires any authenticated user.
    """
    items = db.query(models.Item).offset(skip).limit(limit).all()
    return items


@api_router.get("/items/{item_id}", response_model=schemas.Item, tags=["Items"])
def get_item(item_id: int, db: Session = Depends(get_db)):
    """
    Get a specific item by ID.
    This endpoint requires any authenticated user.
    """
    item = db.query(models.Item).filter(models.Item.id == item_id).first()
    if item is None:
        from fastapi import HTTPException

        raise HTTPException(status_code=404, detail="Item not found")
    return item


# --- CONTEXT-AWARE ENDPOINTS (Template Examples) ---
# These endpoints show where you can add your own authorization logic:
# 1. Fetch data needed for the context from database
# 2. Build the context for your authorization rules
# 3. Implement your own authorization checks as needed


# Example: Database-driven ownership check
@api_router.put("/items/{item_id}", tags=["Context Scenarios"])
def update_item(
    item_id: int,
    request: Request,
    db: Session = Depends(get_db),
):
    """
    Update an item. No authorization required in template.
    Developers can add their own authorization logic as needed.
    """
    item = db.query(models.Item).filter(models.Item.id == item_id).first()
    if not item:
        from fastapi import HTTPException

        raise HTTPException(status_code=404, detail="Item not found")

    # No authorization check - developers can add their own logic here

    # Update the item
    item.name = f"Updated: {item.name}"
    db.commit()
    return {"status": "Item updated", "item": item}


# Additional context-aware examples (simplified for template clarity)
@api_router.get("/analytics/{region}", tags=["Context Scenarios"])
def get_analytics(region: str, request: Request):
    """Analytics endpoint - no authorization required in template."""
    # No authorization check - developers can add their own logic here
    return {"region": region, "sales": 12345}


@api_router.get("/secure-asset", tags=["Context Scenarios"])
def get_secure_asset(
    request: Request,
    x_forwarded_for: str | None = Header(None),
):
    """Secure asset endpoint - no geofencing required in template."""
    country = "US"  # Default
    if geoip_reader and x_forwarded_for:
        try:
            country = geoip_reader.country(
                x_forwarded_for.split(",")[0]
            ).country.iso_code
        except geoip2.errors.AddressNotFoundError:
            country = "UNKNOWN"
    
    # No authorization check - developers can add geofencing logic here
    return {"asset": "Public Data", "source_country": country}


# For additional context-aware scenarios, see the authorization documentation

# Include the router in the main app
app.include_router(api_router)
