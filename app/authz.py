# app/authz.py
"""
Simplified authorization module with authentication removed.
All endpoints are now public - developers can add their own auth system as needed.
"""
import logging
from fastapi import Request

# --- Logger Setup ---
log = logging.getLogger(__name__)


class AuthzEngine:
    """
    Simplified authorization engine - allows all requests.
    Developers can implement their own policy-based authorization here.
    """

    def __init__(self, public_map_path=None, authz_map_path=None):
        """Initialize with no policies - everything is public."""
        log.info("Initializing simplified authorization engine (all requests allowed)")

    def check(self, request: Request, user: dict | None, context: dict = None):
        """
        Simplified authorization check - allows all requests.
        Developers can implement their own authorization logic here.
        """
        # Allow all requests - no authorization required
        return True
