"""Application entry point and factory."""

from fastapi import FastAPI

from api.http.router import router


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    app = FastAPI(title="API")
    app.include_router(router)
    return app


app = create_app()
