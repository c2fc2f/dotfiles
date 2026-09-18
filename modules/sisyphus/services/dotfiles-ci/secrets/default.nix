{
  custom.secrets.sisyphus.enable = true;

  sops.secrets = {
    "dotfiles-ci/env" = {
      sopsFile = ./env;
      format = "binary";
    };
  };
}
