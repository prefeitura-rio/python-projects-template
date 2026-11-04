"""Tests for api.config.Settings."""

from pathlib import Path

import pytest

from api.config import Settings, settings

_ENV_VARS = ("APP_ENV", "APP_HOST", "APP_PORT")


@pytest.fixture
def clean_env(monkeypatch: pytest.MonkeyPatch, tmp_path: Path) -> pytest.MonkeyPatch:
    """Isolate Settings from the caller's environment and from any local .env file."""
    for name in _ENV_VARS:
        monkeypatch.delenv(name, raising=False)
    monkeypatch.chdir(tmp_path)
    return monkeypatch


def test_settings_defaults(clean_env: pytest.MonkeyPatch) -> None:
    config = Settings()

    assert config.app_env == "development"
    assert config.app_host == "0.0.0.0"
    assert config.app_port == 8000


def test_settings_read_from_environment(clean_env: pytest.MonkeyPatch) -> None:
    clean_env.setenv("APP_ENV", "production")
    clean_env.setenv("APP_HOST", "127.0.0.1")
    clean_env.setenv("APP_PORT", "9000")

    config = Settings()

    assert config.app_env == "production"
    assert config.app_host == "127.0.0.1"
    assert config.app_port == 9000


def test_settings_read_from_env_file(clean_env: pytest.MonkeyPatch, tmp_path: Path) -> None:
    (tmp_path / ".env").write_text("APP_ENV=staging\nAPP_PORT=8080\n", encoding="utf-8")

    config = Settings()

    assert config.app_env == "staging"
    assert config.app_host == "0.0.0.0"
    assert config.app_port == 8080


def test_settings_rejects_invalid_port(clean_env: pytest.MonkeyPatch) -> None:
    clean_env.setenv("APP_PORT", "not-a-number")

    with pytest.raises(ValueError):
        Settings()


def test_module_exposes_settings_instance() -> None:
    assert isinstance(settings, Settings)
