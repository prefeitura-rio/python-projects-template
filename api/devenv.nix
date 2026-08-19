# devenv.nix — Development environment for the FastAPI template.
#
# Provides Python 3.13 and uv for local development. Tool versions are pinned
# by the nixpkgs snapshot in devenv.lock — never pin individual packages here.
#
# Quality checks (formatting, linting, type-checking, tests) are owned by the
# CI quality gate action (prefeitura-rio/actions). See https://devenv.sh.

{ pkgs, config, ... }:

{
  name = "api";

  # UV_PYTHON tells uv to use the Nix-managed Python interpreter, not any
  # system Python. Without this, uv may pick up the wrong version or a
  # non-reproducible interpreter from the host.
  env = {
    UV_PYTHON = config.languages.python.package.outPath;
  };

  languages.python = {
    enable = true;
    package = pkgs.python313;
    lsp.package = pkgs.basedpyright;
    uv = {
      enable = true;
      sync = {
        enable = true;    # auto-run `uv sync` when entering the dev shell
        allGroups = true; # include the dev dependency group (ruff, basedpyright, pytest…)
      };
    };
  };

  git-hooks.hooks = {
    ripsecrets.enable = true;

    no-commit-to-branch = {
      enable = true;
      settings.branch = [ "master" "main" ];
    };
  };
}
