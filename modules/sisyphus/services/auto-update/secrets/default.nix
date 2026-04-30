{
  custom.secrets.sisyphus.enable = true;

  sops.secrets = {
    "auto-update/env" = {
      sopsFile = ./env;
      format = "binary";
    };
  };
}
