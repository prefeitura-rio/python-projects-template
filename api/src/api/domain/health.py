"""Domain types for the health check endpoint."""

from typing import Literal

from pydantic import BaseModel

HealthStatus = Literal["ok", "degraded", "down"]


class HealthResponse(BaseModel):
    """Response body returned by GET /health."""

    status: HealthStatus
