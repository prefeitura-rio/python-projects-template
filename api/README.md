# FastAPI Template

A minimal, production-ready FastAPI REST API starter. Copy the contents of
this directory into a new repository root and start building.

## Stack

| Concern | Choice |
|---|---|
| Language | Python 3.13 |
| Framework | FastAPI (async, Pydantic, automatic OpenAPI docs) |
| Package manager | uv |
| Dev environment | devenv (Nix-based, reproducible) |
| Git hooks | `ripsecrets` + `no-commit-to-branch` |
| Formatting | ruff format |
| Linting | ruff check + basedpyright |
| Tests | pytest + pytest-asyncio + httpx |
| CI | GitHub Actions → `prefeitura-rio/actions/quality-gate@latest` |

## Project structure

```
src/api/
├── main.py          # App factory: create_app() → FastAPI
├── config.py        # Pydantic Settings — reads environment variables
├── domain/
│   └── health.py    # Pure domain types (HealthStatus, HealthResponse)
├── http/
│   ├── router.py    # Top-level APIRouter — includes all sub-routers
│   └── handler/
│       └── health.py # GET /health handler
├── repository/      # Data access layer (placeholder)
└── service/         # Business logic layer (placeholder)
tests/
├── conftest.py      # Shared AsyncClient fixture
└── test_health.py   # Health endpoint tests
```

The source code lives under `src/api/` (the "src layout"). This prevents
Python from accidentally importing from the project root rather than the
installed package, which avoids subtle import bugs during testing.

## How to use

1. Copy this directory into a new, empty repository:
   ```bash
   cp -r python-projects-template/api/. my-new-api/
   cd my-new-api
   ```
2. Update `name` in `pyproject.toml` and `devenv.nix`.
3. Rename `src/api/` to match your service name and update imports accordingly.
4. Bootstrap the dev environment:
   ```bash
   bash scripts/bootstrap.sh
   # Open a new terminal, then:
   devenv allow
   ```
5. Verify everything works:
   ```bash
   uv run pytest
   uv run ruff check .
   uv run ruff format --check .
   ```

## Running locally

```bash
uv run uvicorn api.main:app --reload
```

The API is now available at `http://localhost:8000`. Swagger UI is at
`http://localhost:8000/docs`.

## App factory pattern

`create_app()` in `main.py` constructs and configures the FastAPI instance.
The module-level `app` is what uvicorn uses in production. Tests call
`create_app()` directly and pass the result to `httpx.AsyncClient` — no real
TCP port is ever bound during testing:

```python
from httpx import ASGITransport, AsyncClient
from api.main import create_app

async def test_my_endpoint(client: AsyncClient) -> None:
    response = await client.get("/my-endpoint")
    assert response.status_code == 200
```

## Configuration

Environment variables are declared in `src/api/config.py` as a
`pydantic_settings.BaseSettings` subclass. Add a field there to expose a new
variable:

```python
class Settings(BaseSettings):
    database_url: str = "postgresql://localhost/mydb"
```

Copy `.env.example` to `.env` for local overrides (`.env` is gitignored).

## CI pipeline

Five jobs run on every push and pull request to `main`:

```
format ──┐
lint   ──┤
strlint──┼──> test
typecheck┘
```

`format`, `lint`, `strlint`, and `typecheck` run in parallel. `test` runs
only after all four pass. The `typecheck` job is a no-op for Python — type
checking is handled by basedpyright inside the `lint` job.
