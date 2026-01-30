{
  custom.secrets.sisyphe.enable = true;

  sops.secrets."vaultwarden/env" = {
    sopsFile = ./secrets.yaml;
  };
}
