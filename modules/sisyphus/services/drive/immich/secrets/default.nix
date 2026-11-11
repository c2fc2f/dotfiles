{
  custom.secrets.sisyphus.enable = true;

  sops.secrets = {
    "immich/client/secret" = {
      sopsFile = ./secrets.yaml;

      owner = "kanidm";
      group = "kanidm";
    };
  };
}
