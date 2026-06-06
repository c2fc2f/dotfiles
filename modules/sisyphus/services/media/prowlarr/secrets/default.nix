{
  custom.secrets.sisyphus.enable = true;

  sops.secrets."prowlarr/apiKey" = {
    sopsFile = ./secrets.yaml;
  };
}
