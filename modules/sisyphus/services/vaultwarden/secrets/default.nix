{
  custom.secrets.sisyphus.enable = true;

  sops.secrets."vaultwarden/admin/token" = {
    sopsFile = ./secrets.yaml;
  };
}
