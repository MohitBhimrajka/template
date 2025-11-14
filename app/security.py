# app/security.py
"""
Simplified security module with authentication removed.
All endpoints are now public - developers can add their own auth system as needed.
"""
import logging
from fastapi import Request

# --- Logger Setup ---
log = logging.getLogger(__name__)


def get_current_user() -> dict | None:
    """
    Simplified user function - returns None (no authentication).
    Developers can implement their own authentication system here.
    """
    return None


def verify_access(request: Request):
    """
    Simplified access verification - allows all requests.
    All endpoints are now public. Developers can implement 
    their own authorization system here.
    """
    # Allow all requests - no authentication required
    return
