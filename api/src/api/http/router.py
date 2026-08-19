"""Top-level API router.

All sub-routers are included here and then registered on the FastAPI app in
main.py. Adding a new feature group means: create a handler module, define a
router there, and include it below.
"""

from fastapi import APIRouter

from api.http.handler import health

router = APIRouter()
router.include_router(health.router)
