"""Application entry point.

The app factory pattern (create_app) mirrors Fastify's createServer() in the
TypeScript template:
  - create_app() constructs and configures the FastAPI application.
  - The module-level `app` is used by uvicorn in production.
  - Tests call create_app() directly and pass the result to AsyncClient,
    so no real TCP port is ever bound during testing.

Run locally:
    uv run uvicorn api.main:app --reload
"""

from fastapi import FastAPI

from api.http.router import router


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    app = FastAPI(title="API")
    app.include_router(router)
    return app


# Module-level instance used by uvicorn:
#   uv run uvicorn api.main:app --reload
app = create_app()
