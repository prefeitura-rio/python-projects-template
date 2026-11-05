# STYLEGUIDE.md

Each template is an independent project with its own style guide, copied with
it into the new repository:

- [`api/STYLEGUIDE.md`](./api/STYLEGUIDE.md): FastAPI template (layers, handlers,
  configuration, tests through the app factory).
- [`library/STYLEGUIDE.md`](./library/STYLEGUIDE.md): PyPI library template
  (public API in `__init__.py`, Google-style docstrings).

## Shared by both templates

- src layout: the package lives in `src/<package>/`, tests in `tests/`.
- Absolute imports from the package root, so `scripts/bootstrap.sh` can rename
  the package.
- Type annotations on every function, tests included; a docstring at the top
  of every non-empty module.
- Same tool configuration: ruff format (line length 100, double quotes), ruff
  check with `E`, `F`, `I`, `N`, `W`, `UP`, basedpyright in `standard` mode for
  Python 3.13, and the ast-grep rules in `.quality-gate/rules/`
  (`no-bare-except`, `no-print` outside tests, `no-eval`).
- Tests in `tests/test_<module>.py`, functions named `test_<behavior>`.

A convention that applies to both templates must be changed in both style
guides, like any other change shared by the templates (see `AGENTS.md`).
