# Python Project Templates

A collection of minimal, production-ready Python project starters. Each
template is an independent, self-contained repository — copy the contents of
the relevant subdirectory into a new repository root and start building.

## Available templates

| Template | Description | Framework |
|---|---|---|
| [`api/`](./api/) | Async HTTP REST API | FastAPI 0.115, Python 3.13 |
| [`library/`](./library/) | Publishable PyPI package | hatchling + uv |

## What every template shares

Both templates use the same conventions so patterns learned in one apply to
the other:

| Concern | Choice |
|---|---|
| Language | Python 3.13 |
| Package manager | uv (replaces pip, virtualenv, pip-tools) |
| Dev environment | devenv (Nix-based, reproducible) |
| Git hooks | `ripsecrets` + `no-commit-to-branch` |
| Formatting | ruff format |
| Linting | ruff check + basedpyright |
| Structural linting | ast-grep (org-wide rules via `quality-gate`) |
| Tests | pytest + pytest-cov |
| CI | GitHub Actions → `prefeitura-rio/actions/quality-gate@latest` |

## CI pipeline structure

Every template ships an identical `.github/workflows/ci.yaml` with five jobs:

```
format ──┐
lint   ──┤
strlint──┼──> test
typecheck┘
```

The four checks run in parallel. `test` runs only after all four pass. This
keeps feedback fast: a formatting error does not block linting, and tests only
run on code that has already passed static analysis.

The `typecheck` job is a no-op for Python — basedpyright runs inside the
`lint` job. The job is kept in the workflow to maintain a consistent five-job
matrix across all language templates.

## How to use a template

1. Copy the template subdirectory into a new, empty repository:
   ```bash
   cp -r python-projects-template/api/. my-new-api/
   cd my-new-api
   ```
2. Update `name` in `pyproject.toml` and `devenv.nix`.
3. For the library template, also rename `src/my_library/` and update
   `[tool.hatch.build.targets.wheel] packages` in `pyproject.toml`.
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

## Template-specific docs

Each template contains its own `README.md` with detailed usage instructions,
stack choices, and testing guidance:

- [api/README.md](./api/README.md)
- [library/README.md](./library/README.md)
