"""Top-level API router."""

from fastapi import APIRouter

from api.http.handler import health

router = APIRouter()
router.include_router(health.router)
