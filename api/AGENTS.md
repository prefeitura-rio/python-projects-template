# AGENTS.md

Async FastAPI REST API (Python 3.13, uv). See `README.md` for the stack and the
project structure.

Run every command from this directory, the project root (`api/` inside
`python-projects-template`).

## Setup

```bash
uv sync --frozen
```

`devenv shell` provides the same environment, plus `ast-grep` and the git
hooks.

## Test

```bash
uv run --frozen pytest
uv run --frozen pytest --cov=src --cov-report=term-missing   # as CI runs it (app:test)
```

## Format, lint and type check

```bash
uv run --frozen ruff format --check .                  # app:format
uv run --frozen ruff check .                           # app:lint
uv run --frozen basedpyright                           # app:lint (type check)
ast-grep scan --config .quality-gate/sgconfig.yaml     # app:strlint
```

To apply fixes: `uv run --frozen ruff format .` and
`uv run --frozen ruff check --fix .`.

`ast-grep` is installed by devenv, not by uv. Outside devenv, run
`uvx --from ast-grep-cli ast-grep scan --config .quality-gate/sgconfig.yaml`.

`app:typecheck` is a no-op for Python: type checking is done by basedpyright.

## Run

```bash
uv run --frozen uvicorn api.main:app --app-dir src --reload
```

The project is not installed as a package, so `--app-dir src` is required.
`api` is the package name until `scripts/bootstrap.sh` renames it.

## Before you push

All the checks above must pass. They are the jobs of the quality gate
(`app:format`, `app:lint`, `app:strlint`, `app:typecheck`, then `app:test`),
also defined as devenv tasks in `devenv.nix` (`devenv tasks run app:<task>`).
