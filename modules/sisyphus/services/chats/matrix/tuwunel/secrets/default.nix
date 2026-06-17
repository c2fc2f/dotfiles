{
  custom.secrets.sisyphus.enable = true;

  sops.secrets."matrix-tuwunel/client/secret" = {
    sopsFile = ./secrets.yaml;
  };
}
