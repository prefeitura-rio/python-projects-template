{ pkgs, config, ... }:

{
  name = "library";

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
        enable = true;
        allGroups = true;
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
