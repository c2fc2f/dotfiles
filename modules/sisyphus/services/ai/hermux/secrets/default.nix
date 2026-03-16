{
  custom.secrets.sisyphus.enable = true;

  sops.secrets = {
    "hermux/tokens" = {
      sopsFile = ./tokens.csv;
      format = "binary";

      owner = "hermux";
    };
  };
}
