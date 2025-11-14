# tests/test_main.py
import pytest
from httpx import AsyncClient

from app.main import app

# Mark all tests in this file as async
pytestmark = pytest.mark.asyncio


async def test_health_check():
    """
    Tests the public health check endpoint.
    """
    async with AsyncClient(app=app, base_url="http://test") as ac:
        response = await ac.get("/api/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


async def test_unauthorized_access():
    """
    Tests that protected endpoints require authentication.
    """
    async with AsyncClient(app=app, base_url="http://test") as ac:
        response = await ac.get("/api/test")
    assert response.status_code == 401


# Additional tests would include:
# - Database integration tests
# - Authorization engine tests
# - API endpoint tests with mocked authentication
# - Model validation tests
