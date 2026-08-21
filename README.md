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
| CI | GitHub Actions → `prefeitura-rio/actions/quality-gate@master` |

## CI pipeline structure

Every template ships an identical `.github/workflows/quality-gate.yaml` with five jobs:

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

The `api/` template additionally ships `.github/workflows/sast.yaml` — security
scanning (opengrep, grype/SBOM, checkov, SonarQube) via the org reusable
workflow `prefeitura-rio/actions/.github/workflows/sast.yml`. See
[api/README.md](./api/README.md) for the required secrets and variables.

## How to use a template

Copy the desired template subdirectory into a new, empty repository and run its
bootstrap script. For example:

```bash
cp -r python-projects-template/api/. my-new-api/
cd my-new-api
bash scripts/bootstrap.sh
```

The script prompts for the project name, derives Python package names where
needed, performs the renames and substitutions, installs the development
environment, and trusts the project automatically. Open a **new terminal** after
the script finishes.

Follow the template-specific README for verification commands.

## Template-specific docs

Each template contains its own `README.md` with detailed usage instructions,
stack choices, and testing guidance:

- [api/README.md](./api/README.md)
- [library/README.md](./library/README.md)
