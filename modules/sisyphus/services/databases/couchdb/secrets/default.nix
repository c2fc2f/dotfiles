{ config, ... }:

{
  custom.secrets.sisyphus.enable = true;

  sops.secrets."couchdb/admin" = {
    sopsFile = ./admin;
    format = "binary";

    owner = config.services.couchdb.user;
  };
}
