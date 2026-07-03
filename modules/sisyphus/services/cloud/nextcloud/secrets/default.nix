{
  custom.secrets.sisyphus.enable = true;

  sops.secrets."nextcloud/client/secret" = {
    sopsFile = ./secrets.yaml;
  };
}
