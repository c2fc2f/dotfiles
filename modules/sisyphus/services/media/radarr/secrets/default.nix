{
  custom.secrets.sisyphus.enable = true;

  sops.secrets."radarr/apiKey" = {
    sopsFile = ./secrets.yaml;
  };
}
