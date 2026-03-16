{
  custom.secrets.sisyphus.enable = true;

  sops.secrets."cloudflare/dns-api-token" = {
    sopsFile = ./secrets.yaml;
  };
}
