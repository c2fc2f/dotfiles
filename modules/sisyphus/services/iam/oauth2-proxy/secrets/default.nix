{
  custom.secrets.sisyphus.enable = true;

  sops.secrets = {
    "oauth2-proxy/client/secret" = {
      sopsFile = ./secrets.yaml;

      owner = "kanidm";
      group = "kanidm";
    };
    "oauth2-proxy/cookie/secret".sopsFile = ./secrets.yaml;
  };
}
