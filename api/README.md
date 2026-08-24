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
| Git hooks | `ripsecrets` + `no-commit-to-branch` + format/lint/strlint (pre-commit) + typecheck/test (pre-push) |
| Formatting | ruff format |
| Linting | ruff check + basedpyright |
| Tests | pytest + pytest-asyncio + httpx |
| CI | GitHub Actions → `prefeitura-rio/actions/quality-gate@master` |

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

Copy this directory into a new, empty repository and run the bootstrap script:

```bash
cp -r python-projects-template/api/. my-new-api/
cd my-new-api
bash scripts/bootstrap.sh
```

The script prompts for the project name, derives the Python package name, renames
`src/api/`, updates imports and project metadata, installs the development
environment, and trusts the project automatically. Open a **new terminal** after
the script finishes.

Verify everything works:

```bash
devenv tasks run app:test
devenv tasks run app:lint:check
devenv tasks run app:format:check
```

## Running quality checks locally

devenv tasks wrap the same tools CI uses. Run them with `devenv tasks run`:

```bash
devenv tasks run app:format           # ruff format .
devenv tasks run app:format:check     # ruff format --check .
devenv tasks run app:lint             # ruff check --fix + basedpyright
devenv tasks run app:lint:check       # ruff check + basedpyright
devenv tasks run app:strlint           # ast-grep scan
devenv tasks run app:typecheck         # no-op (covered by app:lint)
devenv tasks run app:test              # pytest
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

## Security scanning (SAST)

In addition to the quality gate, `.github/workflows/sast.yaml` runs security
scanning (opengrep, grype/SBOM, checkov, SonarQube) by calling the org reusable
workflow `prefeitura-rio/actions/.github/workflows/sast.yml`.

The workflow requires the following secrets and variables at the repository or
organization level:

| Name | Type | Purpose |
|---|---|---|
| `SONAR_HOST_URL` | Variable | SonarQube server URL |
| `SONAR_TOKEN` | Secret | SonarQube access token |
| `DD_TOKEN` | Secret | DefectDojo API token |
| `TS_TAGS` | Secret | Tailscale tags for the runner |
| `TS_OAUTH_CLIENT_ID` | Secret | Tailscale OAuth client ID |
| `TS_OAUTH_SECRET` | Secret | Tailscale OAuth client secret |

Until these exist, the `sast` job will fail — configure them before enabling
the workflow.
