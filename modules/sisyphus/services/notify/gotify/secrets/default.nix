{
  custom.secrets.sisyphus.enable = true;

  sops.secrets."gotify/admin/password" = {
    sopsFile = ./secrets.yaml;
  };
  sops.secrets."gotify/client/secret" = {
    sopsFile = ./secrets.yaml;
  };
}
