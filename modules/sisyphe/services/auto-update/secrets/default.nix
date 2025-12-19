{
  sops.secrets = {
    "auto-update/env" = {
      sopsFile = ./env;
      format = "binary";
    };
  };
}
