{
  custom.secrets.sisyphus.enable = true;

  sops.secrets."vaultwarden/admin/token" = {
    sopsFile = ./secrets.yaml;
  };
  sops.secrets."vaultwarden/client/secret" = {
    sopsFile = ./secrets.yaml;
  };
}
