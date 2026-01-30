{
  custom.secrets.sisyphe.enable = true;

  sops.secrets."immich/oauth/secret" = {
    sopsFile = ./secrets.yaml;
  };
}
