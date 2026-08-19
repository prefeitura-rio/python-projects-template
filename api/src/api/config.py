"""Application configuration.

Settings are read from environment variables using pydantic-settings.
Add a new field here to expose a new environment variable to the application.

Example usage:
    from api.config import settings
    print(settings.app_env)
"""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    app_env: str = "development"
    app_host: str = "0.0.0.0"
    app_port: int = 8000


# Module-level singleton — import this in handlers and services.
settings = Settings()
