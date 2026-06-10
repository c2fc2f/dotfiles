{
  custom.secrets.sisyphus.enable = true;

  sops.secrets."sonarr/apiKey" = {
    sopsFile = ./secrets.yaml;
  };
}
