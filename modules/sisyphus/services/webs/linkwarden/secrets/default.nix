{ config, ... }:
let
  secretConfig = {
    sopsFile = ./secrets.yaml;

    owner = config.services.linkwarden.user;
    inherit (config.services.linkwarden) group;
  };
in
{
  custom.secrets.sisyphus.enable = true;

  sops.secrets = {
    "linkwarden/nextauth/secret" = secretConfig;
    "linkwarden/client/secret" = secretConfig;
  };

}
