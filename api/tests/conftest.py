"""Shared pytest fixtures.

The AsyncClient fixture is shared across all test modules. It uses
httpx.ASGITransport to call the FastAPI app directly without binding a real
TCP port — equivalent to Fastify's app.inject() in the TypeScript template.
"""

import pytest
from httpx import ASGITransport, AsyncClient

from api.main import create_app


@pytest.fixture
async def client() -> AsyncClient:  # type: ignore[override]
    """Return an AsyncClient wired to the FastAPI app under test."""
    app = create_app()
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test",
    ) as ac:
        yield ac
