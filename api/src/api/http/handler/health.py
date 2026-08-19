"""Health check handler."""

from fastapi import APIRouter

from api.domain.health import HealthResponse

router = APIRouter()


@router.get("/health", response_model=HealthResponse)
async def health() -> HealthResponse:
    """Return the current health status of the service."""
    return HealthResponse(status="ok")
