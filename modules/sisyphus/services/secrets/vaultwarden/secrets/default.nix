{
  custom.secrets.sisyphus.enable = true;

  sops.secrets = {
    "vaultwarden/client/secret" = {
      sopsFile = ./secrets.yaml;

      owner = "kanidm";
      group = "kanidm";
    };
    "vaultwarden/admin/token" = {
      sopsFile = ./secrets.yaml;
    };
  };
}
