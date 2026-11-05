# STYLEGUIDE.md

Code conventions of the FastAPI template. They describe what the template code
already does; follow them when adding code so new modules look like the
existing ones. Tooling that enforces part of them is listed at the end. For
commands, see `AGENTS.md`.

## Layout

The code uses the src layout: the package is `src/api/` (renamed by
`scripts/bootstrap.sh`), tests live in `tests/`, outside the package.

```
src/api/
├── main.py          # create_app() and the module-level app
├── config.py        # Settings (pydantic-settings) and the settings instance
├── domain/          # Pydantic models and types, no I/O
├── http/
│   ├── router.py    # Top-level APIRouter, includes every handler router
│   └── handler/     # One module per resource, each with its own APIRouter
├── repository/      # Data access (empty placeholder)
└── service/         # Business logic (empty placeholder)
```

## Layers

- `domain/`: request and response models (`pydantic.BaseModel`) and value types
  (`typing.Literal` aliases such as `HealthStatus`). No FastAPI, no I/O.
- `http/handler/<resource>.py`: declares `router = APIRouter()` and the route
  functions of that resource. Handlers are `async def`, declare
  `response_model=` and a return type from `domain/`, and stay thin.
- `http/router.py`: the only place that includes handler routers
  (`router.include_router(<resource>.router)`).
- `service/` for business logic and `repository/` for data access. They are
  empty in the template; when used, handlers call services and services call
  repositories, not the other way around.
- `main.py`: `create_app()` builds and configures the `FastAPI` instance and
  includes `http.router.router`; `app = create_app()` is what uvicorn serves.

To add an endpoint: models in `domain/<resource>.py`, routes in
`http/handler/<resource>.py`, then include the router in `http/router.py`.

## Configuration

All configuration is read through `Settings` in `config.py`, a
`pydantic_settings.BaseSettings` subclass with typed fields and defaults.
Fields are `snake_case` and map to upper-case environment variables
(`app_port` ← `APP_PORT`); a local `.env` file is also read and is ignored by
git. Import the shared instance (`from api.config import settings`) instead of
reading `os.environ` directly.

## Imports

- Absolute imports from the package root: `from api.domain.health import HealthResponse`.
  `scripts/bootstrap.sh` renames the package by rewriting `from api.` and
  `import api.`, so relative imports and bare `import api` are not used.
- Import order and grouping are ruff's isort rules (`I`): standard library,
  third party, then the package.

## Naming and types

- Modules and functions `snake_case`, classes `PascalCase`, constants
  `UPPER_CASE`; module-private names start with `_` (pep8-naming, ruff `N`).
- Every function has parameter and return annotations, tests and fixtures
  included (`-> None`). Use modern syntax (`X | None`, `list[str]`) and
  `collections.abc` for abstract types (ruff `UP`).
- The code has no `# type: ignore`: fix the type instead of silencing basedpyright.

## Docstrings

- Every module starts with a one-line docstring (`"""Health check handler."""`).
  Empty `__init__.py` files have none.
- Domain models, the app factory, handlers and fixtures have a one-line
  docstring saying what they return or represent.

## Errors and logging

- No bare `except:`; catch a specific exception type.
- No `print()` in `src/`; use `logging.getLogger(__name__)`.
- No `eval()` or `exec()`.

## Tests

- `tests/test_<module>.py`, flat, one file per module or endpoint, with a
  module docstring (`"""Tests for GET /health."""`).
- Test functions are named `test_<behavior>`, have no docstring and are
  annotated `-> None`.
- Endpoints are tested through the `client` fixture of `tests/conftest.py`
  (`httpx.AsyncClient` over `ASGITransport(app=create_app())`); no real port is
  bound. Async tests need no marker (`asyncio_mode = "auto"`).
- Tests that read the environment isolate it with `monkeypatch` and `tmp_path`
  (see `tests/test_config.py`).

## Enforced by tooling

| Rule | Tool (config) |
|---|---|
| Formatting: line length 100, double quotes | ruff format (`pyproject.toml`) |
| Lint rules `E`, `F`, `I`, `N`, `W`, `UP` | ruff check (`pyproject.toml`) |
| Types, mode `standard`, Python 3.13 | basedpyright (`pyproject.toml`) |
| `no-bare-except`, `no-print` (outside tests), `no-eval` | ast-grep (`.quality-gate/rules/`) |
