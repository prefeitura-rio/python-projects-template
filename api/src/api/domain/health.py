"""Domain types for the health check endpoint."""

from typing import Literal

from pydantic import BaseModel

# A union of the valid status strings. Using Literal restricts the field to
# exactly these values and makes the OpenAPI schema an enum automatically.
HealthStatus = Literal["ok", "degraded", "down"]


class HealthResponse(BaseModel):
    """Response body returned by GET /health."""

    status: HealthStatus
